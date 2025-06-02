// lib/services/friends_location_service.dart
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class FriendsLocationService {
  static final FriendsLocationService _instance = FriendsLocationService._internal();
  factory FriendsLocationService() => _instance;
  FriendsLocationService._internal() {
    _locationController = StreamController<Map<String, Map<String, dynamic>>>.broadcast();

    // Firebase 인증 상태 변경 리스너 추가
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        debugPrint('🔐 Firebase 인증됨: ${user.uid}');
        _currentUserId = user.uid;
        _isAuthenticated = true;

        // 인증 상태가 변경되면 위치 추적 시작
        _startLocationTracking();

        // 인증된 상태에서 친구 위치 요청
        if (_isConnected && !_isDisposed) {
          requestAllFriendsLocations();
        }
      } else {
        debugPrint('🔒 Firebase 인증되지 않음');
        _isAuthenticated = false;
        _currentUserId = null;

        // 익명 인증 시도 코드 제거됨
      }
    });
  }

  StreamSubscription? _locationSubscription;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isConnected = false;
  bool _isDisposed = false;
  bool _isAuthenticated = false;
  bool _isTrackingLocation = false;
  String? _currentUserId;
  Position? _lastPosition;

  final String _firebaseDbUrl = 'https://tripjoy-d309f-default-rtdb.asia-southeast1.firebasedatabase.app/';
  // 컬렉션을 friends_location으로 변경
  final DatabaseReference _database = FirebaseDatabase.instance.ref('friends_location');

  // friends ID를 키로 하고 위치 정보를 값으로 하는 Map
  final Map<String, Map<String, dynamic>> _friendsLocations = {};

  // 위치 업데이트 스트림 컨트롤러
  late final StreamController<Map<String, Map<String, dynamic>>> _locationController;

  // 위치 업데이트 최소 거리 (미터 단위)
  double _minimumDistanceChange = 10.0;

  Stream<Map<String, Map<String, dynamic>>> get locationStream => _locationController.stream;

  // 익명 인증 메서드 제거됨

  Future<void> initialize() async {
    _isDisposed = false;
    if (!_locationController.isClosed) {
      // 먼저 Firebase 인증 상태 확인
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        _currentUserId = currentUser.uid;
        _isAuthenticated = true;
        debugPrint('🔐 이미 인증됨: ${currentUser.uid}');
      }

      await connect();
    }
  }

  Future<void> connect() async {
    if (_isConnected || _isDisposed) return;

    try {
      debugPrint('🔥 Firebase Realtime Database 연결 시도 중...');

      // Firebase 리얼타임 데이터베이스 설정
      FirebaseDatabase.instance.databaseURL = _firebaseDbUrl;

      _isConnected = true;
      debugPrint('✅ Firebase Realtime Database 연결 성공');

      // 기존에 저장된 위치 정보가 있으면 즉시 스트림으로 전송
      if (_friendsLocations.isNotEmpty && !_locationController.isClosed) {
        _locationController.add(_friendsLocations);
      }

      // Firebase 리얼타임 데이터베이스 리스너 설정
      _locationSubscription = _database.onValue.listen(
            (DatabaseEvent event) {
          _handleDatabaseEvent(event);
        },
        onError: (error) {
          if (_isDisposed) return;
          debugPrint('❌ Firebase 데이터베이스 에러 발생: $error');
          _isConnected = false;
          reconnect();
        },
      );

      // 인증 상태와 관계없이 친구 위치 요청 (friends_location은 public 읽기 권한이 있음)
      if (!_isDisposed) {
        requestAllFriendsLocations();
      }

      // 인증된 상태에서만 위치 추적 시작
      if (_isAuthenticated && !_isDisposed) {
        _startLocationTracking();
      }

    } catch (e) {
      debugPrint('❌ Firebase 연결 에러: $e');
      _isConnected = false;
      if (!_isDisposed) {
        reconnect();
      }
    }
  }

  void _handleDatabaseEvent(DatabaseEvent event) {
    if (_isDisposed) return;

    debugPrint('📨 Firebase 데이터 수신');

    try {
      final data = event.snapshot.value;
      if (data == null) {
        debugPrint('⚠️ 수신된 데이터가 없습니다.');
        return;
      }

      // 데이터가 맵 형태로 전달됨 (유저 ID를 키로 사용)
      if (data is Map) {
        Map<Object?, Object?> locationsMap = data as Map<Object?, Object?>;

        // 모든 친구의 위치 정보 처리
        locationsMap.forEach((key, value) {
          if (key is String && value is Map) {
            final userId = key;
            final locationData = Map<String, dynamic>.from(value as Map);

            // 필요한 필드가 모두 있는지 확인
            if (locationData.containsKey('latitude') &&
                locationData.containsKey('longitude') &&
                locationData.containsKey('timestamp')) {

              final latitude = locationData['latitude'] as double;
              final longitude = locationData['longitude'] as double;
              final timestamp = locationData['timestamp'];

              final newLocationData = {
                'latitude': latitude,
                'longitude': longitude,
                'timestamp': timestamp,
              };

              // 위치 정보가 실제로 변경되었을 때만 업데이트
              if (_friendsLocations[userId]?.toString() != newLocationData.toString()) {
                _friendsLocations[userId] = newLocationData;
                debugPrint('📍 friends 위치 업데이트 - ID: $userId, 위도: $latitude, 경도: $longitude, 시간: $timestamp');
              }
            }
          }
        });

        // 전체 위치 정보를 스트림으로 전송
        if (!_locationController.isClosed) {
          _locationController.add(_friendsLocations);
        }
      }
    } catch (e) {
      debugPrint('❌ 데이터 파싱 에러: $e');
    }
  }

  void _handleDataSnapshot(DataSnapshot snapshot) {
    if (_isDisposed) return;

    debugPrint('📨 Firebase 데이터 스냅샷 수신');

    try {
      final data = snapshot.value;
      if (data == null) {
        debugPrint('⚠️ 수신된 데이터가 없습니다.');
        return;
      }

      // 데이터가 맵 형태로 전달됨 (유저 ID를 키로 사용)
      if (data is Map) {
        Map<Object?, Object?> locationsMap = data as Map<Object?, Object?>;

        // 모든 친구의 위치 정보 처리
        locationsMap.forEach((key, value) {
          if (key is String && value is Map) {
            final userId = key;
            final locationData = Map<String, dynamic>.from(value as Map);

            // 필요한 필드가 모두 있는지 확인
            if (locationData.containsKey('latitude') &&
                locationData.containsKey('longitude') &&
                locationData.containsKey('timestamp')) {

              final latitude = locationData['latitude'] as double;
              final longitude = locationData['longitude'] as double;
              final timestamp = locationData['timestamp'];

              final newLocationData = {
                'latitude': latitude,
                'longitude': longitude,
                'timestamp': timestamp,
              };

              // 위치 정보가 실제로 변경되었을 때만 업데이트
              if (_friendsLocations[userId]?.toString() != newLocationData.toString()) {
                _friendsLocations[userId] = newLocationData;
                debugPrint('📍 friends 위치 업데이트 - ID: $userId, 위도: $latitude, 경도: $longitude, 시간: $timestamp');
              }
            }
          }
        });

        // 전체 위치 정보를 스트림으로 전송
        if (!_locationController.isClosed) {
          _locationController.add(_friendsLocations);
        }
      }
    } catch (e) {
      debugPrint('❌ 데이터 파싱 에러: $e');
    }
  }

  void requestAllFriendsLocations() {
    if (_isConnected && !_isDisposed) {
      _database.get().then((DataSnapshot snapshot) {
        _handleDataSnapshot(snapshot);
        debugPrint('📤 모든 friends 위치 요청 완료');
      }).catchError((error) {
        debugPrint('❌ friends 위치 요청 에러: $error');
      });
    }
  }

  // 위치 정보 업데이트
  Future<void> updateMyLocation(String userId, double latitude, double longitude) async {
    if (!_isConnected || _isDisposed) return;

    try {
      // 이전 위치가 있고, 거리가 최소 거리 변화보다 작으면 업데이트 안 함
      if (_lastPosition != null) {
        final distanceInMeters = Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            latitude,
            longitude
        );

        if (distanceInMeters < _minimumDistanceChange) {
          debugPrint('🔍 위치 변화 무시: ${distanceInMeters.toStringAsFixed(2)}m (최소 기준: ${_minimumDistanceChange}m)');
          return;
        }

        debugPrint('📏 위치 변화 감지: ${distanceInMeters.toStringAsFixed(2)}m (최소 기준: ${_minimumDistanceChange}m)');
      }

      final timestamp = DateTime.now().toIso8601String();

      // 기존 데이터 확인 (먼저 데이터를 가져와서 기존 값이 있는지 확인)
      final snapshot = await _database.child(userId).get();

      Map<String, dynamic> newData = {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp,
      };

      if (snapshot.exists) {
        // 기존 데이터가 있으면 추가 정보 유지
        final existingData = Map<String, dynamic>.from(snapshot.value as Map);

        // userId는 경로로 사용되므로 중복 저장하지 않음
        existingData.remove('userId');

        // 위치 및 타임스탬프 정보만 업데이트
        existingData['latitude'] = latitude;
        existingData['longitude'] = longitude;
        existingData['timestamp'] = timestamp;

        // 업데이트된 데이터 저장
        await _database.child(userId).update(existingData);
        debugPrint('📤 기존 위치 정보 업데이트 완료 - ID: $userId');
      } else {
        // 새 데이터 저장
        await _database.child(userId).set(newData);
        debugPrint('📤 새 위치 정보 저장 완료 - ID: $userId');
      }
    } catch (e) {
      debugPrint('❌ 위치 업데이트 에러: $e');
    }
  }

  // 위치 추적 시작
  Future<void> _startLocationTracking() async {
    if (_isTrackingLocation || _isDisposed) return;

    debugPrint('📍 위치 추적 초기화 중...');

    await _positionStreamSubscription?.cancel();

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      debugPrint('🔒 위치 권한 요청 중...');
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint('❌ 위치 권한이 거부됨');
      return;
    }

    debugPrint('✅ 위치 권한 획득, 스트림 설정 시작');

    _isTrackingLocation = true;
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 10미터 이상 이동 시 업데이트
      ),
    ).listen(
          (Position position) {
        // 이제 위치 변경 감지 및 필터링은 updateMyLocation에서 처리
        _lastPosition = position;

        // 인증된 상태에서만 위치 업데이트
        if (_isAuthenticated && _currentUserId != null) {
          updateMyLocation(_currentUserId!, position.latitude, position.longitude);
        }
      },
      onError: (error) {
        debugPrint('❌ 위치 스트림 에러: $error');
        _isTrackingLocation = false;
      },
    );

    debugPrint('✅ 위치 추적 시작됨');
  }

  // 위치 추적 중지
  void _stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _isTrackingLocation = false;
    _lastPosition = null;
    debugPrint('🛑 위치 추적 중지됨');
  }

  void reconnect() {
    if (_isDisposed) return;
    debugPrint('🔄 Firebase 재연결 시도 예약 (5초 후)');
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isConnected && !_isDisposed) {
        connect();
      }
    });
  }

  double calculateDistance(String friendsId, Position myLocation) {
    if (_isDisposed || !_friendsLocations.containsKey(friendsId)) {
      return 0.0;
    }

    final friendsLocation = _friendsLocations[friendsId]!;
    final distance = Geolocator.distanceBetween(
      myLocation.latitude,
      myLocation.longitude,
      friendsLocation['latitude']!,
      friendsLocation['longitude']!,
    ) / 1000;  // 미터를 킬로미터로 변환

    debugPrint('📏 거리 계산 - friends ID: $friendsId, 거리: ${distance.toStringAsFixed(1)}km');
    return distance;
  }

  Map<String, dynamic>? getFriendsLocation(String friendsId) {
    if (_isDisposed) return null;
    return _friendsLocations[friendsId];
  }

  void dispose() {
    debugPrint('🧹 FriendsLocationService 정리 중...');
    _isDisposed = true;

    // 위치 추적 중지
    _stopLocationTracking();

    // 스트림 구독 취소
    _locationSubscription?.cancel();
    _locationSubscription = null;

    // 위치 업데이트 스트림 닫기
    if (!_locationController.isClosed) {
      _locationController.close();
    }

    _isConnected = false;
    debugPrint('✅ FriendsLocationService 정리 완료');
  }

  bool get isConnected => _isConnected;
  bool get isAuthenticated => _isAuthenticated;
}
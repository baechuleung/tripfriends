// features/profile/services/profile_media_service.dart
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileMediaService {
  final Function(bool) onMediaLoadingStateChanged;

  List<Map<String, dynamic>> _profileMedia = [];
  Map<String, VideoPlayerController> _videoControllers = {};
  int _currentMediaIndex = 0;

  ProfileMediaService({required this.onMediaLoadingStateChanged});

  // Getters
  List<Map<String, dynamic>> get profileMedia => _profileMedia;
  Map<String, VideoPlayerController> get videoControllers => _videoControllers;
  int get currentMediaIndex => _currentMediaIndex;

  // Setters
  set currentMediaIndex(int index) {
    // 현재 비디오 일시정지
    if (_currentMediaIndex < _profileMedia.length &&
        _profileMedia[_currentMediaIndex]['type'] == 'video') {
      final String currentUrl = _profileMedia[_currentMediaIndex]['url'];
      if (_videoControllers.containsKey(currentUrl)) {
        _videoControllers[currentUrl]?.pause();
      }
    }

    _currentMediaIndex = index;
  }

  // 이미 생성된 모든 비디오 컨트롤러 해제
  void dispose() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
    _profileMedia.clear();
  }

  // 이미지 미리 로드 (Flutter 내장 기능 사용) - 크기 제한 추가
  void _precacheImages(List<String> imageUrls, BuildContext? context) {
    if (context == null) return;

    for (var url in imageUrls) {
      // 메모리 최적화: 작은 크기로 프리캐싱
      precacheImage(
        ResizeImage(
          NetworkImage(url),
          width: 800,  // 최대 너비 제한
          height: 800, // 최대 높이 제한
        ),
        context,
      );
    }
  }

  // Firestore에서 프로필 미디어 로드 (최적화)
  Future<void> loadProfileMedia(String userId, [BuildContext? context]) async {
    onMediaLoadingStateChanged(true);

    // 기존 비디오 컨트롤러 해제
    dispose();

    try {
      // Firestore에서 사용자 데이터 가져오기
      final docSnapshot = await FirebaseFirestore.instance
          .collection('tripfriends_users')
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        // profileMediaList가 있는 경우
        if (data['profileMediaList'] != null && data['profileMediaList'] is List) {
          final mediaList = List<Map<String, dynamic>>.from(data['profileMediaList']);

          List<Map<String, dynamic>> mediaItems = [];
          List<String> imageUrls = [];

          // Firestore에 저장된 순서대로 미디어 아이템 처리
          for (int i = 0; i < mediaList.length; i++) {
            final item = mediaList[i];
            final url = item['path'] as String;
            final type = item['type'] as String;

            if (type == 'image') {
              imageUrls.add(url);
            }

            // 순서를 유지하면서 mediaItems에 추가
            mediaItems.add({
              'url': url,
              'type': type,
              'order': i,
            });
          }

          _profileMedia = mediaItems;

          // 이미지 프리캐싱 (최적화된 크기로)
          if (context != null && imageUrls.isNotEmpty) {
            _precacheImages(imageUrls, context);
          }
        } else if (data['profileImageUrl'] != null) {
          // 구 버전 호환성: profileImageUrl만 있는 경우
          _profileMedia = [{
            'url': data['profileImageUrl'],
            'type': 'image',
            'order': 0,
          }];

          // 단일 이미지도 프리캐싱
          if (context != null) {
            _precacheImages([data['profileImageUrl']], context);
          }
        }
      }
    } catch (e) {
      print('프로필 미디어 로드 오류: $e');
    } finally {
      onMediaLoadingStateChanged(false);
    }
  }

  // 기본 미디어 설정
  void setDefaultMedia(Map<String, dynamic> userData) {
    _profileMedia = [];
    _currentMediaIndex = 0;

    if (userData['profileImageUrl'] != null) {
      _profileMedia = [{
        'url': userData['profileImageUrl'],
        'type': 'image',
        'order': 0,
      }];
    }
  }

  // 비디오 컨트롤러 생성
  Future<VideoPlayerController?> createVideoController(String url) async {
    if (_videoControllers.containsKey(url)) {
      return _videoControllers[url];
    }

    try {
      final controller = VideoPlayerController.network(url);
      await controller.initialize();
      _videoControllers[url] = controller;
      return controller;
    } catch (e) {
      print('비디오 컨트롤러 생성 오류: $e');
      return null;
    }
  }

  // 현재 미디어가 비디오인지 확인
  bool get isCurrentMediaVideo {
    if (_currentMediaIndex >= _profileMedia.length) return false;
    return _profileMedia[_currentMediaIndex]['type'] == 'video';
  }

  // 현재 미디어 URL 가져오기
  String? get currentMediaUrl {
    if (_currentMediaIndex >= _profileMedia.length) return null;
    return _profileMedia[_currentMediaIndex]['url'];
  }

  // 비디오 재생/일시정지 토글
  void toggleVideoPlayback(String url) {
    if (_videoControllers.containsKey(url)) {
      final controller = _videoControllers[url]!;
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    }
  }
}
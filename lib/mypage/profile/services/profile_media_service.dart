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
  }

  // 이미지 미리 로드 (Flutter 내장 기능 사용)
  void _precacheImages(List<String> imageUrls, BuildContext? context) {
    if (context == null) return;

    for (var url in imageUrls) {
      precacheImage(NetworkImage(url), context);
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
            });
          }

          print('로드된 미디어 순서: ${mediaItems.map((e) => e['type']).toList()}');

          // 이미지 프리캐싱
          if (context != null && imageUrls.isNotEmpty) {
            _precacheImages(imageUrls, context);
          }

          // 비디오 컨트롤러 초기화
          final videoItems = mediaItems.where((item) => item['type'] == 'video').toList();
          if (videoItems.isNotEmpty) {
            final videoInitFutures = videoItems.map((item) => _initVideoController(item['url']));
            await Future.wait(videoInitFutures);
          }

          _profileMedia = mediaItems;
        } else {
          // profileMediaList가 없으면 기본 이미지 설정
          setDefaultMedia(data);
        }
      } else {
        // 문서가 없으면 빈 리스트
        _profileMedia = [];
      }

      onMediaLoadingStateChanged(false);
    } catch (e) {
      print('미디어 로드 오류: $e');
      _profileMedia = [];
      onMediaLoadingStateChanged(false);
    }
  }

  // 비디오 컨트롤러 초기화
  Future<void> _initVideoController(String url) async {
    try {
      // 이미 초기화된 컨트롤러가 있는지 확인
      if (_videoControllers.containsKey(url)) {
        return;
      }

      final controller = VideoPlayerController.network(url);
      await controller.initialize();
      controller.setLooping(true);
      _videoControllers[url] = controller;
    } catch (e) {
      print('비디오 컨트롤러 초기화 오류: $e');
    }
  }

  // 비디오 재생/일시정지 토글
  void toggleVideoPlayback(String url) {
    if (_videoControllers.containsKey(url)) {
      if (_videoControllers[url]!.value.isPlaying) {
        _videoControllers[url]!.pause();
      } else {
        _videoControllers[url]!.play();
      }
    }
  }

  // 미디어가 비어있으면, 기본 미디어 설정
  void setDefaultMedia(Map<String, dynamic> userData) {
    // 기본 이미지가 있는 경우 사용
    if (userData['profileImageUrl'] != null && userData['profileImageUrl'].toString().isNotEmpty) {
      _profileMedia = [{'url': userData['profileImageUrl'], 'type': 'image'}];
    } else {
      // 아니면 기본 아바타 이미지 사용
      _profileMedia = [{'url': 'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y', 'type': 'image'}];
    }
    onMediaLoadingStateChanged(false);
  }
}
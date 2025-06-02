// features/profile/services/profile_media_service.dart
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';

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

  // Firebase Storage에서 사용자 프로필 이미지와 영상 로드 (최적화)
  Future<void> loadProfileMedia(String userId, [BuildContext? context]) async {
    onMediaLoadingStateChanged(true);

    // 기존 비디오 컨트롤러 해제
    dispose();

    try {
      // Storage 경로: tripfriends_profiles/userId/ 아래의 모든 파일
      final storageRef = FirebaseStorage.instance.ref().child('tripfriends_profiles/$userId');

      try {
        // 폴더 내의 모든 항목 나열
        final listResult = await storageRef.listAll();

        // 미디어 URL 리스트 초기화
        List<Map<String, dynamic>> mediaItems = [];
        List<String> imageUrls = []; // 이미지 URL 모음

        // 각 항목에 대한 다운로드 URL 병렬 가져오기
        final urlFutures = listResult.items.map((item) async {
          try {
            String fileName = item.name.toLowerCase();
            String url = await item.getDownloadURL();

            // 이미지 파일 필터링
            if (fileName.endsWith('.jpg') ||
                fileName.endsWith('.jpeg') ||
                fileName.endsWith('.png') ||
                fileName.endsWith('.gif') ||
                fileName.endsWith('.webp')) {
              imageUrls.add(url); // 이미지 URL 추가
              return {
                'url': url,
                'type': 'image',
                'fileName': fileName // 정렬용 파일명 추가
              };
            }
            // 비디오 파일 필터링
            else if (fileName.endsWith('.mp4') ||
                fileName.endsWith('.mov') ||
                fileName.endsWith('.avi') ||
                fileName.endsWith('.webm') ||
                fileName.endsWith('.mkv')) {
              return {
                'url': url,
                'type': 'video',
                'fileName': fileName // 정렬용 파일명 추가
              };
            }
          } catch (e) {
            print('아이템 URL 가져오기 오류: $e');
          }
          return null;
        });

        // 모든 URL을 병렬로 가져오기 (타임아웃 설정)
        List<Map<String, dynamic>?> results = [];
        try {
          results = await Future.wait(
            urlFutures,
            eagerError: false,
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('URL 가져오기 타임아웃');
              return []; // 단순히 빈 리스트 반환
            },
          );
        } catch (e) {
          print('URL 처리 중 오류: $e');
        }

        // null이 아닌 결과만 필터링하여 mediaItems에 추가
        mediaItems = results.where((item) => item != null).cast<Map<String, dynamic>>().toList();

        // 파일명 기준으로 정렬 (선택사항)
        if (mediaItems.isNotEmpty) {
          mediaItems.sort((a, b) => a['fileName'].compareTo(b['fileName']));

          // 파일명 필드 제거 (필요 없음)
          for (var item in mediaItems) {
            item.remove('fileName');
          }
        }

        // 내장 Flutter 이미지 캐싱
        if (context != null) {
          _precacheImages(imageUrls, context);
        }

        // 비디오 컨트롤러 초기화 (병렬로 시작)
        final videoItems = mediaItems.where((item) => item['type'] == 'video').toList();
        if (videoItems.isNotEmpty) {
          final videoInitFutures = videoItems.map((item) => _initVideoController(item['url']));
          await Future.wait(videoInitFutures);
        }

        _profileMedia = mediaItems;
        onMediaLoadingStateChanged(false);
      } catch (e) {
        print('Storage 항목 나열 오류: $e');
        _profileMedia = [];
        onMediaLoadingStateChanged(false);
      }
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
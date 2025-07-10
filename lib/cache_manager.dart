// cache_manager.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AggressiveCacheManager {
  static Timer? _timer;
  static Timer? _aggressiveTimer;
  static const int MAX_CACHE_SIZE = 50 * 1024 * 1024; // 50MB로 제한
  static const int AGGRESSIVE_CACHE_SIZE = 30 * 1024 * 1024; // 30MB 넘으면 즉시 정리

  // 앱 시작 시 초기화
  static void initialize() {
    // 매우 공격적인 이미지 캐시 설정
    PaintingBinding.instance.imageCache.maximumSize = 30; // 이미지 30개만
    PaintingBinding.instance.imageCache.maximumSizeBytes = 20 * 1024 * 1024; // 20MB만

    // 2분마다 정기 정리
    _timer = Timer.periodic(Duration(minutes: 2), (timer) {
      clearAllCaches();
    });

    // 30초마다 공격적 체크
    _aggressiveTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _aggressiveCacheCheck();
    });

    print('✅ 공격적 캐시 매니저 시작됨');
  }

  // 공격적인 캐시 체크
  static void _aggressiveCacheCheck() {
    final imageCache = PaintingBinding.instance.imageCache;

    // 이미지 캐시가 15MB 넘으면 즉시 정리
    if (imageCache.currentSizeBytes > 15 * 1024 * 1024) {
      print('⚠️ 이미지 캐시 15MB 초과 - 즉시 정리');
      imageCache.clear();
    }

    // 이미지 개수가 20개 넘으면 절반 제거
    if (imageCache.currentSize > 20) {
      print('⚠️ 이미지 개수 20개 초과 - 절반 제거');
      imageCache.evict;
    }
  }

  // 모든 캐시 완전 정리
  static Future<void> clearAllCaches() async {
    print('🧹 공격적 캐시 정리 시작...');

    try {
      // 1. 이미지 캐시 완전 초기화
      final imageCache = PaintingBinding.instance.imageCache;
      imageCache.clear();
      imageCache.clearLiveImages();

      // 2. 캐시 크기 재설정 (더 작게)
      imageCache.maximumSize = 20;
      imageCache.maximumSizeBytes = 15 * 1024 * 1024;

      // 3. 네트워크 이미지 캐시 정리
      await _clearNetworkImageCache();

      // 4. 임시 디렉토리 완전 정리
      await _clearTempDirectory();

      // 5. 앱 데이터 캐시 정리
      await _clearAppCache();

      print('✅ 캐시 정리 완료');
    } catch (e) {
      print('❌ 캐시 정리 실패: $e');
    }
  }

  // 네트워크 이미지 캐시 완전 제거
  static Future<void> _clearNetworkImageCache() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();

      // 가능한 모든 캐시 디렉토리 정리
      final List<String> cacheDirs = [
        'image_cache',
        'network_image_cache',
        'cached_network_image',
        'flutter_cache',
      ];

      for (String dirName in cacheDirs) {
        final Directory cacheDir = Directory('${tempDir.path}/$dirName');
        if (await cacheDir.exists()) {
          await cacheDir.delete(recursive: true);
          print('🗑️ $dirName 디렉토리 삭제됨');
        }
      }
    } catch (e) {
      print('❌ 네트워크 캐시 정리 실패: $e');
    }
  }

  // 임시 디렉토리 공격적 정리
  static Future<void> _clearTempDirectory() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();

      // 모든 파일 리스트
      final List<FileSystemEntity> files = tempDir.listSync(recursive: true);

      for (var file in files) {
        if (file is File) {
          try {
            // 파일 크기 체크
            final int fileSize = await file.length();

            // 1MB 이상 파일은 무조건 삭제
            if (fileSize > 1024 * 1024) {
              await file.delete();
              print('🗑️ 큰 파일 삭제: ${file.path} (${fileSize ~/ 1024}KB)');
            }

            // 1시간 이상 된 파일 삭제
            final DateTime modified = await file.lastModified();
            if (DateTime.now().difference(modified).inHours > 1) {
              await file.delete();
              print('🗑️ 오래된 파일 삭제: ${file.path}');
            }
          } catch (e) {
            // 파일 삭제 실패 시 계속 진행
          }
        }
      }
    } catch (e) {
      print('❌ 임시 디렉토리 정리 실패: $e');
    }
  }

  // 앱 캐시 디렉토리 정리
  static Future<void> _clearAppCache() async {
    try {
      final Directory appCacheDir = await getApplicationCacheDirectory();

      if (await appCacheDir.exists()) {
        final List<FileSystemEntity> files = appCacheDir.listSync(recursive: true);

        for (var file in files) {
          if (file is File) {
            await file.delete();
          }
        }
        print('🗑️ 앱 캐시 디렉토리 정리됨');
      }
    } catch (e) {
      print('❌ 앱 캐시 정리 실패: $e');
    }
  }

  // 메모리 압박 시 즉시 정리
  static void emergencyClear() {
    print('🚨 긴급 메모리 정리 실행');

    // 이미지 캐시 즉시 초기화
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.clear();
    imageCache.clearLiveImages();

    // 더 작은 크기로 재설정
    imageCache.maximumSize = 10;
    imageCache.maximumSizeBytes = 10 * 1024 * 1024;

    // 비동기로 나머지 정리
    clearAllCaches();
  }

  // 정리
  static void dispose() {
    _timer?.cancel();
    _aggressiveTimer?.cancel();
  }
}
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/translation_service.dart';

/// 지도 관련 기능을 제공하는 서비스 클래스
class MapService {
  /// 싱글톤 패턴 구현
  static final MapService _instance = MapService._internal();
  factory MapService() => _instance;
  MapService._internal();

  /// 지도 열기 - 웹 기반 구글 지도 사용
  ///
  /// [address] - 검색할 주소
  /// [context] - BuildContext (오류 메시지 표시용)
  /// [translationService] - 번역 서비스 인스턴스
  Future<bool> openMap(
      String address,
      BuildContext context,
      TranslationService translationService) async {
    try {
      final String encodedAddress = Uri.encodeComponent(address);

      // 웹 브라우저에서 구글 지도 URL 사용
      final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');

      // 웹 URL로 시도
      bool launched = false;
      if (await launchUrl(
        googleMapsUrl,
        mode: LaunchMode.externalApplication,
      )) {
        launched = true;
      }

      // 실패했다면 오류 메시지 표시
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  translationService.get(
                      'map_error',
                      '지도를 열 수 없습니다. 인터넷 연결을 확인해주세요.'
                  )
              ),
              duration: const Duration(seconds: 2),
            )
        );
      }

      return launched;
    } catch (e) {
      debugPrint('지도를 열 수 없습니다: $e');

      // 오류 발생 시 사용자에게 알림
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  translationService.get(
                      'map_error',
                      '지도를 열 수 없습니다. 인터넷 연결을 확인해주세요.'
                  )
              ),
              duration: const Duration(seconds: 2),
            )
        );
      }

      return false;
    }
  }
}
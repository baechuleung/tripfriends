import 'package:flutter/material.dart';

/// 간단한 라우터 설정 파일
/// main.dart에 추가해서 사용
class AppRoutes {
  /// 앱의 모든 라우트 정의
  static Map<String, WidgetBuilder> getRoutes(Widget mainPage) {
    return {
      '/main': (context) => mainPage,
    };
  }
}
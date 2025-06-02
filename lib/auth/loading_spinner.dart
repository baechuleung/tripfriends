import 'package:flutter/material.dart';

class LoadingSpinner {
  static OverlayEntry? _overlayEntry;

  // 로딩 스피너 표시
  static void show(BuildContext context) {
    hide(); // 기존에 표시된 것이 있다면 제거

    _overlayEntry = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black.withOpacity(0.5),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  // 로딩 스피너 숨기기
  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
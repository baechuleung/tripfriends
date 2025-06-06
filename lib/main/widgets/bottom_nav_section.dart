import 'package:flutter/material.dart';
import '../../translations/main_translations.dart';
import '../../main.dart' show currentCountryCode, languageChangeController;
import 'dart:async';

class BottomNavSection extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const BottomNavSection({
    super.key,
    this.onNavigateToTab,
  });

  @override
  State<BottomNavSection> createState() => _BottomNavSectionState();
}

class _BottomNavSectionState extends State<BottomNavSection> {
  String _currentLanguage = 'KR';
  StreamSubscription<String>? _languageSubscription;

  @override
  void initState() {
    super.initState();
    _currentLanguage = currentCountryCode;

    // 언어 변경 리스너 등록
    _languageSubscription = languageChangeController.stream.listen((newLanguage) {
      if (mounted) {
        setState(() {
          _currentLanguage = newLanguage;
        });
      }
    });
  }

  @override
  void dispose() {
    _languageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _NavItem(
              iconPath: 'assets/main/encrypted.png',
              label: MainTranslations.getTranslation('my_info', _currentLanguage),
              onTap: () {
                if (widget.onNavigateToTab != null) {
                  widget.onNavigateToTab!(4);
                }
              },
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _NavItem(
              iconPath: 'assets/main/tooltip.png',
              label: MainTranslations.getTranslation('chat_list', _currentLanguage),
              onTap: () {
                if (widget.onNavigateToTab != null) {
                  widget.onNavigateToTab!(3);
                }
              },
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _NavItem(
              iconPath: 'assets/main/shopping_cart.png',
              label: MainTranslations.getTranslation('purchase_ticket', _currentLanguage),
              onTap: () {
                // 이용권 구매 페이지로 이동
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              iconPath,
              width: 26,
              height: 26,
            ),
            const SizedBox(height: 4),
            Container(
              height: 34, // 2줄 높이 고정
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
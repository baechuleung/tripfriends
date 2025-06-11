import 'package:flutter/material.dart';
import '../translations/components_translations.dart';
import '../main.dart';

class TopTabBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final String language;

  const TopTabBar({
    Key? key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.language,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabItem(context, 0, 'assets/main/tab/travel.png', 'travel'),
          _buildTabItem(context, 1, 'assets/main/tab/job.png', 'job_search'),
          _buildTabItem(context, 2, 'assets/main/tab/talk.png', 'talk'),
          _buildTabItem(context, 3, 'assets/main/tab/info.png', 'information'),
        ],
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, int index, String iconPath, String labelKey) {
    final isSelected = selectedIndex == index;
    final translatedLabel = ComponentsTranslations.getTranslation(labelKey, language);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                iconPath,
                width: 36,
                height: 36,
              ),
              const SizedBox(height: 4),
              Text(
                translatedLabel,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF3182F6) : const Color(0xFF1B1C1F),
                  fontSize: 13,
                  fontFamily: 'Spoqa Han Sans Neo',
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
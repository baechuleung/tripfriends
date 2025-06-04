import 'package:flutter/material.dart';

class BottomNavSection extends StatelessWidget {
  final Function(int)? onNavigateToTab;

  const BottomNavSection({
    super.key,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(
            icon: Icons.security,
            label: '내 정보',
            onTap: () {
              if (onNavigateToTab != null) {
                onNavigateToTab!(4);
              }
            },
          ),
          _NavItem(
            icon: Icons.chat,
            label: '채팅 리스트',
            onTap: () {
              if (onNavigateToTab != null) {
                onNavigateToTab!(3);
              }
            },
          ),
          _NavItem(
            icon: Icons.shopping_cart,
            label: '이용권 구매',
            isHighlighted: true,
            onTap: () {
              // 이용권 구매 페이지로 이동
            },
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isHighlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isHighlighted ? Colors.pink : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isHighlighted ? Colors.pink : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
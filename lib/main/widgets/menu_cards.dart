import 'package:flutter/material.dart';

class MenuCards extends StatelessWidget {
  final Function(int)? onNavigateToTab;

  const MenuCards({
    super.key,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 내 정보
        Expanded(
          child: _MenuCard(
            title: '내 정보',
            icon: Icons.person_outline,
            onTap: () {
              if (onNavigateToTab != null) {
                onNavigateToTab!(4);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        // 채팅
        Expanded(
          child: _MenuCard(
            title: '채팅',
            icon: Icons.chat_bubble_outline,
            onTap: () {
              if (onNavigateToTab != null) {
                onNavigateToTab!(3);
              }
            },
          ),
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.grey[700], size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
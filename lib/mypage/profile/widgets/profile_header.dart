// features/profile/widgets/profile_header.dart
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final VoidCallback onEditPressed;
  final Map<String, String> currentLabels;

  const ProfileHeader({
    super.key,
    required this.onEditPressed,
    required this.currentLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // 수정하기 버튼을 오른쪽으로 정렬
        children: [
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: onEditPressed,
            child: Row(
              children: [
                const Icon(Icons.edit, size: 14, color: Color(0xFF3182F6)),
                const SizedBox(width: 4),
                Text(
                  currentLabels['edit'] ?? '수정하기',
                  style: const TextStyle(
                    color: Color(0xFF3182F6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
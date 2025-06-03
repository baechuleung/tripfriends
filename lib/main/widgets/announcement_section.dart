import 'package:flutter/material.dart';

class AnnouncementSection extends StatelessWidget {
  const AnnouncementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: const [
          Icon(Icons.campaign, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Text(
            '리뷰 작성 시 리워드 지급 정책 안내',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class MainFooter extends StatelessWidget {
  const MainFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LEADPROJECT COMPANY Inc.',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              fontFamily: 'Spoqa Han Sans Neo',
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'CEO: Sangho Park | CTO: Chuleung Bae | CDD: Yoonwoo Jung',
            style: TextStyle(
              fontSize: 8,
              fontFamily: 'Spoqa Han Sans Neo',
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Business Registration Number: 413-87-02826',
            style: TextStyle(
              fontSize: 8,
              fontFamily: 'Spoqa Han Sans Neo',
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'E-commerce Registration Number: 2024-Seoul Gwangjin-1870',
            style: TextStyle(
              fontSize: 8,
              fontFamily: 'Spoqa Han Sans Neo',
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Tourism Business License No.: 2024-000022 (Comprehensive Travel Business)',
            style: TextStyle(
              fontSize: 8,
              fontFamily: 'Spoqa Han Sans Neo',
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '14-12, Achasan-ro 62-gil, Gwangjin-gu, Seoul, Republic of Korea (Daeyeong Twin, Guui-dong)',
            style: TextStyle(
              fontSize: 8,
              fontFamily: 'Spoqa Han Sans Neo',
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Tel: 1666-5157',
            style: TextStyle(
              fontSize: 8,
              fontFamily: 'Spoqa Han Sans Neo',
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
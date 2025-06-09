import 'package:flutter/material.dart';
import '../../translations/mypage_translations.dart';
import '../../main.dart'; // currentCountryCode
import 'recommended_friends_controller.dart';
import 'widgets/partner_code_widget.dart';
import 'widgets/friends_list_widget.dart';

class RecommendedFriendsPage extends StatefulWidget {
  const RecommendedFriendsPage({Key? key}) : super(key: key);

  @override
  State<RecommendedFriendsPage> createState() => _RecommendedFriendsPageState();
}

class _RecommendedFriendsPageState extends State<RecommendedFriendsPage> {
  late RecommendedFriendsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RecommendedFriendsController();
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.init();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = currentCountryCode.toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const SizedBox(height: 8),
            PartnerCodeWidget(controller: _controller),
            const SizedBox(height: 8),
            Expanded(
              child: FriendsListWidget(controller: _controller),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        _controller.getTranslatedText('recommended_friends', '프렌즈 리스트'),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }
}
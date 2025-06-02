import 'package:flutter/material.dart';
import 'notifications_page.dart';
import 'inquiry_page.dart';
import '../../services/translation_service.dart';

class SupportPage extends StatefulWidget {
  final int initialTabIndex;

  const SupportPage({
    super.key,
    this.initialTabIndex = 0, // 기본값은 0(공지사항 탭)
  });

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TranslationService _translationService = TranslationService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex, // 초기 탭 인덱스 설정
    );

    // Translation Service 초기화
    _initTranslationService();
  }

  // TranslationService 초기화 함수
  Future<void> _initTranslationService() async {
    await _translationService.init();
    // 상태 업데이트가 필요하면 setState 호출
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 텍스트에 TranslationService 적용
    final String title = _translationService.get('support_center', '고객센터');
    final String notificationsTab = _translationService.get('notifications', '공지사항');
    final String inquiryTab = _translationService.get('one_to_one_inquiry', '1:1 문의');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: const Color(0xFF353535),
          unselectedLabelColor: const Color(0xFF999999),
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            Tab(text: notificationsTab),
            Tab(text: inquiryTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          // 공지사항 탭
          NotificationPage(),

          // 1:1 문의 탭
          InquiryPage(),
        ],
      ),
    );
  }
}
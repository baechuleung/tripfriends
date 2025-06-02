import 'package:flutter/material.dart';
import '../../../services/translation_service.dart';
import 'tabs/usage_tab.dart';
import 'tabs/reservation_tab.dart';
import 'tabs/matching_tab.dart';
import 'tabs/chat_tab.dart';
import 'tabs/payment_tab.dart';
import 'tabs/point_tab.dart';

class ManualDetailPage extends StatefulWidget {
  final TranslationService translationService;

  const ManualDetailPage({
    Key? key,
    required this.translationService,
  }) : super(key: key);

  @override
  State<ManualDetailPage> createState() => _ManualDetailPageState();
}

class _ManualDetailPageState extends State<ManualDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.translationService.get('trip_friends_manual', '트립프렌즈 이용방법'),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            width: double.infinity,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black87,
              indicator: BoxDecoration(
                color: const Color(0xFF4B7BF5),
                borderRadius: BorderRadius.circular(50),
              ),
              indicatorColor: Colors.transparent, // 탭 밑줄 제거
              dividerColor: Colors.transparent, // 탭 구분선 제거
              tabAlignment: TabAlignment.start, // 왼쪽 정렬
              labelPadding: EdgeInsets.zero, // 탭 사이 간격 최소화
              padding: const EdgeInsets.only(left: 16, right: 0), // 좌우 패딩 조정
              tabs: [
                _buildTab(widget.translationService.get('usage_method', '프렌즈 활동방법')),
                _buildTab(widget.translationService.get('reservation', '예약')),
                _buildTab(widget.translationService.get('matching', '매칭')),
                _buildTab(widget.translationService.get('chat', '채팅')),
                _buildTab(widget.translationService.get('payment', '결제')),
                _buildTab(widget.translationService.get('point', '적립금')),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                UsageTab(translationService: widget.translationService),
                ReservationTab(translationService: widget.translationService),
                MatchingTab(translationService: widget.translationService),
                ChatTab(translationService: widget.translationService),
                PaymentTab(translationService: widget.translationService),
                PointTab(translationService: widget.translationService),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
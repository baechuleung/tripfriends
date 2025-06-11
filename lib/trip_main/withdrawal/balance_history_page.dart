import 'package:flutter/material.dart';
import '../../translations/mypage_translations.dart';
import '../../main.dart'; // currentCountryCode
import 'controller/balance_history_controller.dart';
import 'widgets/balance_history_item_widget.dart';

class BalanceHistoryPage extends StatefulWidget {
  const BalanceHistoryPage({Key? key}) : super(key: key);

  @override
  State<BalanceHistoryPage> createState() => _BalanceHistoryPageState();
}

class _BalanceHistoryPageState extends State<BalanceHistoryPage> {
  late BalanceHistoryController _controller;
  String _currentTypeFilter = 'all'; // 'all', 'earn', 'withdrawal'
  String _currentDateFilter = 'all'; // 'all', 'week', 'month', '3months'
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _controller = BalanceHistoryController();
    _loadData();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _loadData() async {
    await _controller.init();
    if (_mounted) {
      setState(() {});
    }
  }

  Future<void> _refreshData() async {
    await _controller.loadBalanceHistory();
    if (_mounted) {
      setState(() {});
    }
  }

  // 필터링된 거래 내역 가져오기
  List<Map<String, dynamic>> get _filteredHistory {
    List<Map<String, dynamic>> result = _controller.balanceHistory;

    // 타입 필터 적용
    if (_currentTypeFilter != 'all') {
      result = result.where((item) => item['type'] == _currentTypeFilter).toList();
    }

    // 날짜 필터 적용
    if (_currentDateFilter != 'all') {
      final now = DateTime.now();
      DateTime startDate;

      switch (_currentDateFilter) {
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month - 1, now.day);
          break;
        case '3months':
          startDate = DateTime(now.year, now.month - 3, now.day);
          break;
        default:
          startDate = DateTime(1900); // 매우 오래된 날짜 (전체)
      }

      result = result.where((item) {
        final itemDate = item['created_at'] as DateTime;
        return itemDate.isAfter(startDate) || itemDate.isAtSameMomentAs(startDate);
      }).toList();
    }

    return result;
  }

  void _changeTypeFilter(String filter) {
    setState(() {
      _currentTypeFilter = filter;
    });
  }

  void _changeDateFilter(String filter) {
    setState(() {
      _currentDateFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = currentCountryCode.toUpperCase();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          MypageTranslations.getTranslation('balance_history', language),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return _buildLoadingState();
    }

    if (_controller.errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    if (_controller.balanceHistory.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildFilterOptions(),
        Expanded(child: _buildBalanceHistoryList()),
      ],
    );
  }

  Widget _buildFilterOptions() {
    final language = currentCountryCode.toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            MypageTranslations.getTranslation('filter_type', language),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTypeFilterButton('all', MypageTranslations.getTranslation('filter_all', language)),
                const SizedBox(width: 8),
                _buildTypeFilterButton('earn', MypageTranslations.getTranslation('filter_earn', language)),
                const SizedBox(width: 8),
                _buildTypeFilterButton('withdrawal', MypageTranslations.getTranslation('filter_withdrawal', language)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            MypageTranslations.getTranslation('filter_period', language),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildDateFilterButton('all', MypageTranslations.getTranslation('filter_period_all', language)),
                const SizedBox(width: 8),
                _buildDateFilterButton('week', MypageTranslations.getTranslation('filter_period_week', language)),
                const SizedBox(width: 8),
                _buildDateFilterButton('month', MypageTranslations.getTranslation('filter_period_month', language)),
                const SizedBox(width: 8),
                _buildDateFilterButton('3months', MypageTranslations.getTranslation('filter_period_3months', language)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTypeFilterButton(String filter, String label) {
    final isSelected = _currentTypeFilter == filter;

    return GestureDetector(
      onTap: () => _changeTypeFilter(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4169E1) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilterButton(String filter, String label) {
    final isSelected = _currentDateFilter == filter;

    return GestureDetector(
      onTap: () => _changeDateFilter(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4169E1) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState() {
    final language = currentCountryCode.toUpperCase();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _controller.errorMessage,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4169E1),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                MypageTranslations.getTranslation('try_again', language),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final language = currentCountryCode.toUpperCase();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              MypageTranslations.getTranslation('no_balance_history', language),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceHistoryList() {
    final language = currentCountryCode.toUpperCase();
    final filteredHistory = _filteredHistory;

    if (filteredHistory.isEmpty) {
      return Center(
        child: Text(
          MypageTranslations.getTranslation('no_filtered_history', language),
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: filteredHistory.length + 1, // +1 for header
      separatorBuilder: (context, index) {
        if (index == 0) return const SizedBox.shrink(); // No separator after header
        return Divider(height: 1, color: Colors.grey[200]);
      },
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildListHeader(filteredHistory.length);
        }
        final historyItem = filteredHistory[index - 1];
        return BalanceHistoryItemWidget(
          historyItem: historyItem,
          controller: _controller,
        );
      },
    );
  }

  Widget _buildListHeader(int itemCount) {
    final language = currentCountryCode.toUpperCase();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                MypageTranslations.getTranslation('total_transactions', language),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '$itemCount${MypageTranslations.getTranslation('count_unit', language)}',
                style: const TextStyle(
                  color: Color(0xFF353535),
                  fontSize: 14,
                  fontFamily: 'Spoqa Han Sans Neo',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
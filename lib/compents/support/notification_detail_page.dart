import 'package:flutter/material.dart';
import 'notification_service.dart';
import '../../services/translation_service.dart';  // TranslationService import 추가

class NotificationDetailPage extends StatefulWidget {
  final String notificationId;
  final String title;
  final String timeInfo;

  const NotificationDetailPage({
    super.key,
    required this.notificationId,
    required this.title,
    required this.timeInfo,
  });

  @override
  State<NotificationDetailPage> createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  bool _isLoading = true;
  String _content = '';
  final TranslationService _translationService = TranslationService();  // TranslationService 인스턴스 추가

  @override
  void initState() {
    super.initState();
    _initTranslationService();
    _loadNotificationDetail();
  }

  // TranslationService 초기화 함수
  Future<void> _initTranslationService() async {
    await _translationService.init();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadNotificationDetail() async {
    try {
      // NotificationService를 통해 공지사항 상세 정보 가져오기
      final announcement = await NotificationService.getAnnouncementDetail(widget.notificationId);

      if (announcement != null && announcement.containsKey('content')) {
        setState(() {
          _content = announcement['content'] as String;
          _isLoading = false;
        });
      } else {
        // 데이터가 없거나 content 필드가 없는 경우 에러 처리
        throw Exception(_translationService.get('notification_content_not_found', '공지사항 내용을 찾을 수 없습니다.'));
      }
    } catch (e) {
      print('${_translationService.get('notification_detail_error', '공지사항 상세 조회 오류')}: $e');

      // 오류 발생 시 사용자에게 알림 (ScaffoldMessenger 대신 print 사용)
      if (mounted) {
        print(_translationService.get('notification_load_error', '공지사항을 불러오는 중 오류가 발생했습니다.'));

        // 오류 발생 시에도 페이지 로딩은 완료
        setState(() {
          _content = _translationService.get('notification_content_load_fail', '공지사항 내용을 불러올 수 없습니다.');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 텍스트 번역 적용
    final String supportCenter = _translationService.get('support_center', '고객센터');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          supportCenter,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Color(0xFF353535),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.timeInfo,
                    style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: const Divider(height: 1, color: Color(0xFFE4E4E4)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _content,
                style: const TextStyle(
                  color: Color(0xFF353535),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
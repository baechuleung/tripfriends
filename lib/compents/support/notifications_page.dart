import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_detail_page.dart';
import 'notification_service.dart';
import '../../services/translation_service.dart';  // TranslationService import 추가

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _announcements = [];
  final TranslationService _translationService = TranslationService();  // TranslationService 인스턴스 추가

  @override
  void initState() {
    super.initState();
    _initTranslationService();
    _loadAnnouncements();
  }

  // TranslationService 초기화 함수
  Future<void> _initTranslationService() async {
    await _translationService.init();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadAnnouncements() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final announcementsData = await NotificationService.getAnnouncements();

      // 공지사항 타입('type' 필드가 'notice'인 항목)만 필터링
      final filteredData = announcementsData
          .where((item) => item['type'] == 'notice')
          .toList();

      if (mounted) {
        setState(() {
          _announcements = filteredData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('${_translationService.get('notification_load_error', '공지사항 로드 오류')}: $e');
      if (mounted) {
        setState(() {
          _announcements = [];
          _isLoading = false;
        });

        // ScaffoldMessenger 대신 print 사용
        print(_translationService.get('notification_load_fail', '공지사항을 불러오는 중 오류가 발생했습니다'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _announcements.isEmpty
          ? Center(child: Text(_translationService.get('no_notifications', '공지사항이 없습니다.')))
          : RefreshIndicator(
        onRefresh: _loadAnnouncements,
        child: ListView.separated(
          itemCount: _announcements.length,
          separatorBuilder: (context, index) => const Divider(height: 0.5, color: Color(0xFFE4E4E4)),
          itemBuilder: (context, index) {
            final announcement = _announcements[index];
            final title = announcement['title'] as String? ?? _translationService.get('default_notification_title', '[알림] 제목 없음');
            final content = announcement['content'] as String? ?? _translationService.get('no_content', '내용 없음');
            final date = announcement['date'] as Timestamp?;
            final notice = announcement['notice'] as String? ?? '';

            String timeInfo;
            if (date != null) {
              final postDate = date.toDate();
              timeInfo = '${postDate.year}.${postDate.month.toString().padLeft(2, '0')}.${postDate.day.toString().padLeft(2, '0')}';
            } else {
              timeInfo = '2024.03.04'; // 기본 날짜
            }

            return ListTile(
              title: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF353535),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeInfo,
                    style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (notice.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _translationService.get(notice.toLowerCase().replaceAll(' ', '_'), notice),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationDetailPage(
                      notificationId: announcement['id'],
                      title: title,
                      timeInfo: timeInfo,
                    ),
                  ),
                ).then((_) {
                  // 상세 페이지에서 돌아온 후 목록 새로고침
                  _loadAnnouncements();
                });
              },
            );
          },
        ),
      ),
    );
  }
}
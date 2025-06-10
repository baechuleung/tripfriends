import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../translations/trip_main_translations.dart';
import '../../main.dart' show currentCountryCode, languageChangeController;
import '../../compents/tripfriends_manual/screens/manual_detail_page.dart';
import '../../services/translation_service.dart';
import 'dart:async';

class BottomNavSection extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const BottomNavSection({
    super.key,
    this.onNavigateToTab,
  });

  @override
  State<BottomNavSection> createState() => _BottomNavSectionState();
}

class _BottomNavSectionState extends State<BottomNavSection> {
  String _currentLanguage = 'KR';
  StreamSubscription<String>? _languageSubscription;
  StreamSubscription? _unreadSubscription;
  bool _hasUnreadMessages = false;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();
    _currentLanguage = currentCountryCode;

    // Firebase Database URL 설정
    _database.databaseURL = 'https://tripjoy-d309f-default-rtdb.asia-southeast1.firebasedatabase.app/';

    // 언어 변경 리스너 등록
    _languageSubscription = languageChangeController.stream.listen((newLanguage) {
      if (mounted) {
        setState(() {
          _currentLanguage = newLanguage;
        });
      }
    });

    // 읽지 않은 메시지 감지
    _listenToUnreadMessages();
  }

  void _listenToUnreadMessages() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _unreadSubscription = _database
        .ref()
        .child('users/${user.uid}/chats')
        .onValue
        .listen((event) {
      if (!mounted) return;

      bool hasUnread = false;

      if (event.snapshot.exists && event.snapshot.value != null) {
        final chatsData = Map<dynamic, dynamic>.from(event.snapshot.value as Map);

        for (var chatData in chatsData.values) {
          if (chatData is Map) {
            final unreadCount = chatData['unreadCount'] ?? 0;
            final isBlocked = chatData['blocked'] ?? false;

            // 차단되지 않은 채팅에서 읽지 않은 메시지가 있는지 확인
            if (!isBlocked && unreadCount > 0) {
              hasUnread = true;
              break;
            }
          }
        }
      }

      setState(() {
        _hasUnreadMessages = hasUnread;
      });
    });
  }

  @override
  void dispose() {
    _languageSubscription?.cancel();
    _unreadSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _NavItem(
              iconPath: 'assets/main/encrypted.png',
              label: MainTranslations.getTranslation('my_info', _currentLanguage),
              onTap: () {
                if (widget.onNavigateToTab != null) {
                  widget.onNavigateToTab!(4);
                }
              },
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _NavItem(
              iconPath: 'assets/main/tooltip.png',
              label: MainTranslations.getTranslation('chat_list', _currentLanguage),
              hasNotification: _hasUnreadMessages,
              onTap: () {
                if (widget.onNavigateToTab != null) {
                  widget.onNavigateToTab!(3);
                }
              },
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _NavItem(
              iconPath: 'assets/main/shopping_cart.png',
              label: MainTranslations.getTranslation('how_to_use', _currentLanguage),
              onTap: () {
                // 트립프렌즈 이용방법 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManualDetailPage(
                      translationService: TranslationService(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;
  final bool hasNotification;

  const _NavItem({
    required this.iconPath,
    required this.label,
    required this.onTap,
    this.hasNotification = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  iconPath,
                  width: 26,
                  height: 26,
                ),
                if (hasNotification)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3E6C),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              height: 34, // 2줄 높이 고정
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
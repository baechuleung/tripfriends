import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'support/support_page.dart';
import 'account_delete_page.dart';
import 'terms/service_terms_screen.dart';
import 'terms/privacy_terms_screen.dart';
import 'terms/location_terms_screen.dart';
import '../services/translation_service.dart';
import 'logout/logout_controller.dart';
import 'logout/logout_popup.dart';

class SettingsDrawer extends StatefulWidget {
  final TranslationService? translationService;

  const SettingsDrawer({Key? key, this.translationService}) : super(key: key);

  @override
  State<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  late TranslationService _translationService;
  late LogoutController _logoutController;
  String _appVersion = "";

  @override
  void initState() {
    super.initState();
    _translationService = widget.translationService ?? TranslationService();
    _logoutController = LogoutController();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        // 버전과 빌드 번호를 함께 표시
        _appVersion = "${packageInfo.version}+${packageInfo.buildNumber}";
      });
    } catch (e) {
      print("버전 정보를 가져오는 중 오류 발생: $e");
      setState(() {
        _appVersion = "1.0.0";
      });
    }
  }

  Widget _buildSectionTitle(String title, String translationKey) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 24.0, bottom: 8.0),
      child: Text(
        _translationService.get(translationKey, title),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildNavigationTile(String title, String translationKey,
      VoidCallback onTap, {bool showDivider = false, IconData? trailingIcon}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(
            _translationService.get(translationKey, title),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.normal,
            ),
          ),
          trailing: Icon(
            trailingIcon ?? Icons.chevron_right,
            size: 18,
            color: Colors.grey,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          onTap: onTap,
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 0.5,
            indent: 16,
            endIndent: 0,
          ),
      ],
    );
  }

  Widget _buildVersionTile(String title, String translationKey, String version,
      {bool showDivider = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(
            _translationService.get(translationKey, title),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.normal,
            ),
          ),
          trailing: Text(
            version,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 0.5,
            indent: 16,
            endIndent: 0,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('서비스 설정', 'service_settings'),

                    // 위치서비스 허용
                    ListTile(
                      title: Text(
                        _translationService.get(
                            'location_service_permission', '위치서비스 허용'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      trailing: Text(
                        _translationService.get('while_using_app', '앱을 사용하는 동안'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                      visualDensity: const VisualDensity(
                          horizontal: 0, vertical: -2),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 16,
                      endIndent: 0,
                    ),

                    _buildSectionTitle('서비스 약관', 'terms_of_service'),

                    _buildNavigationTile('서비스 이용약관', 'terms_service_agreement', () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ServiceTermsScreen()),
                      );
                    }),

                    _buildNavigationTile('위치정보 이용약관', 'terms_location_info', () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LocationTermsScreen()),
                      );
                    }),

                    _buildNavigationTile('개인정보 처리방침', 'privacy_policy', () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PrivacyTermsScreen()),
                      );
                    }, showDivider: true),

                    _buildSectionTitle('고객서비스', 'customer_service'),

                    _buildVersionTile('현재버전', 'current_version', _appVersion),

                    _buildNavigationTile('공지사항', 'notifications', () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SupportPage(),
                        ),
                      );
                    }),

                    _buildNavigationTile('1:1 문의', 'one_to_one_inquiry', () {
                      Navigator.pop(context);
                      // 1:1 문의 탭으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            // TabController를 사용하여 인덱스 1(두 번째 탭)로 초기화된 SupportPage 생성
                            return const SupportPage(
                              initialTabIndex: 1, // 1:1 문의 탭 인덱스
                            );
                          },
                        ),
                      );
                    }),

                    _buildNavigationTile('회원탈퇴', 'delete_account', () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AccountDeletePage()),
                      );
                    }, showDivider: true),

                    _buildNavigationTile('로그아웃', 'logout', () {
                      showLogoutPopup(context, _logoutController, translationService: _translationService);
                    }, trailingIcon: Icons.logout),

                    // 패치 확인용 텍스트
                    Container(
                      alignment: Alignment.bottomRight,
                      padding: const EdgeInsets.only(
                          right: 16.0, bottom: 8.0, top: 20.0),
                      child: const Text(
                        'patch_confirm +1',
                        style: TextStyle(
                          fontSize: 6,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // X 버튼
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 24,
                  color: Colors.black87,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
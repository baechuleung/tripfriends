import 'package:flutter/material.dart';
import 'appbar.dart'; // 기존 앱바 임포트
import '../services/translation_service.dart'; // 필요한 서비스 임포트

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 필요한 파라미터를 가상으로 생성 (실제 실행에는 main_page.dart의 값 사용)
    final Map<String, String> countryNames = {'KR': '한국어', 'US': 'English'};

    return Scaffold(
      // main_page.dart에 있는 동일한 앱바 사용
      appBar: TripFriendsAppBar(
        countryNames: countryNames,
        currentCountryCode: 'KR',
        onCountryChanged: (value) {},
        refreshKeys: () {},
        isLoggedIn: true,  // isLoggedIn 파라미터 추가
        translationService: TranslationService(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildSectionTitle('서비스 설정'),
            const SizedBox(height: 8),
            _buildSettingsItem(
              '위치서비스 허용',
              '앱을 사용하는 동안',
              true,
              textColor: Colors.blue,
            ),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 20),

            _buildSectionTitle('알림 설정'),
            const SizedBox(height: 8),
            _buildToggleItem('예약 요청 알림', false),
            const Divider(height: 1, thickness: 0.5),
            _buildToggleItem('마케팅 정보 알림', true),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 20),

            _buildSectionTitle('서비스 약관'),
            const SizedBox(height: 8),
            _buildNavigationItem('서비스 이용약관'),
            const Divider(height: 1, thickness: 0.5),
            _buildNavigationItem('위치정보 이용약관'),
            const Divider(height: 1, thickness: 0.5),
            _buildNavigationItem('개인정보 처리방침'),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 20),

            _buildSectionTitle('고객서비스'),
            const SizedBox(height: 8),
            _buildVersionItem('현재버전', '12.1 v'),
            const Divider(height: 1, thickness: 0.5),
            _buildNavigationItem('공지사항'),
            const Divider(height: 1, thickness: 0.5),
            _buildNavigationItem('1:1 문의'),
            const Divider(height: 1, thickness: 0.5),
            _buildNavigationItem('회원탈퇴'),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => _showTranslationDialog(title),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
      String title,
      String value,
      bool hasChevron,
      {Color textColor = Colors.black}
      ) {
    return GestureDetector(
      onTap: () => _showTranslationDialog(title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () => _showTranslationDialog(value),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                ),
                if (hasChevron) const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(String title, bool value) {
    return GestureDetector(
      onTap: () => _showTranslationDialog(title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            Switch(
              value: value,
              onChanged: (newValue) {},
              activeColor: Colors.green,
              activeTrackColor: Colors.lightGreen.shade200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItem(String title) {
    return GestureDetector(
      onTap: () => _showTranslationDialog(title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionItem(String title, String version) {
    return GestureDetector(
      onTap: () => _showTranslationDialog(title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            Text(
              version,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTranslationDialog(String text) {
    // 여기서는 실제 번역 대화상자 구현만 설명합니다
    // 실제 앱에서는 context를 사용하여 팝업을 표시해야 합니다
    print('번역 다이얼로그 표시: $text');
  }
}
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../services/shared_preferences_service.dart';
import '../translations/version_translations.dart';

class VersionUpdatePopup extends StatelessWidget {
  final bool isForceUpdate;
  final String message;
  final String? iosUrl;
  final String? androidUrl;

  const VersionUpdatePopup({
    Key? key,
    required this.isForceUpdate,
    required this.message,
    this.iosUrl,
    this.androidUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String language = SharedPreferencesService.getLanguage() ?? 'KR';

    return WillPopScope(
      onWillPop: () async => !isForceUpdate,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30, 20, 30, 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아이콘
              Image.asset(
                'assets/main/bell.png',
                width: 80,
                height: 80,
              ),
              const SizedBox(height: 15),

              // 제목
              Text(
                isForceUpdate
                    ? VersionTranslations.getTranslation('force_update_title', language)
                    : VersionTranslations.getTranslation('new_version_available', language),
                style: const TextStyle(
                  color: Color(0xFF353535),
                  fontSize: 20,
                  fontFamily: 'Spoqa Han Sans Neo',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),

              // 버튼들
              if (isForceUpdate) ...[
                // 필수 업데이트 - 업데이트 버튼만
                SizedBox(
                  width: double.infinity,
                  child: _buildUpdateButton(context, language),
                ),
              ] else ...[
                // 선택 업데이트 - 세로로 정렬된 두 개의 버튼
                SizedBox(
                  width: double.infinity,
                  child: _buildUpdateButton(context, language),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: _buildLaterButton(context, language),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLaterButton(BuildContext context, String language) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(
        VersionTranslations.getTranslation('update_later', language),
        style: const TextStyle(
          color: Color(0xFF999999),
          fontSize: 14,
          fontFamily: 'Spoqa Han Sans Neo',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildUpdateButton(BuildContext context, String language) {
    return ElevatedButton(
      onPressed: () async {
        final String? storeUrl = Platform.isIOS ? iosUrl : androidUrl;

        if (storeUrl != null && storeUrl.isNotEmpty) {
          final Uri url = Uri.parse(storeUrl);
          if (await canLaunchUrl(url)) {
            await launchUrl(
              url,
              mode: LaunchMode.externalApplication,
            );
          } else {
            // URL을 열 수 없는 경우
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(VersionTranslations.getTranslation('cannot_open_store', language)),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        }

        // 선택 업데이트인 경우에만 팝업 닫기
        if (!isForceUpdate && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5B6FED),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.download,
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            isForceUpdate
                ? VersionTranslations.getTranslation('update_now', language)
                : VersionTranslations.getTranslation('go_to_update', language),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Spoqa Han Sans Neo',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// 팝업 표시 함수
void showVersionUpdatePopup({
  required BuildContext context,
  required bool isForceUpdate,
  String message = '',
  String? iosUrl,
  String? androidUrl,
}) {
  showDialog(
    context: context,
    barrierDismissible: !isForceUpdate,
    builder: (BuildContext context) {
      return VersionUpdatePopup(
        isForceUpdate: isForceUpdate,
        message: message,
        iosUrl: iosUrl,
        androidUrl: androidUrl,
      );
    },
  );
}
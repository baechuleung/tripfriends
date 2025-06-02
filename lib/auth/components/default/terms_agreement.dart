import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../controller/default/terms_agreement_controller.dart';
import '../../../main.dart';

class TermsAgreement extends StatefulWidget {
  final TermsAgreementController controller;

  const TermsAgreement({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<TermsAgreement> createState() => _TermsAgreementState();
}

class _TermsAgreementState extends State<TermsAgreement> {
  Map<String, String> currentLabels = {
    "terms_agreement": "이용약관 동의",
    "agree_all": "모든 약관에 동의",
    "service_terms": "[필수] 서비스 이용약관",
    "privacy_terms": "[필수] 개인정보수집/이용동의",
    "location_terms": "[필수] 위치기반 서비스 이용약관 동의",
  };

  @override
  void initState() {
    super.initState();
    loadTranslations();
  }

  Future<void> loadTranslations() async {
    try {
      final String translationJson = await rootBundle.loadString('assets/data/auth_translations.json');
      final translationData = json.decode(translationJson);

      if (mounted) {
        setState(() {
          final translations = translationData['translations'];
          if (translations['terms_agreement'] != null &&
              translations['agree_all'] != null &&
              translations['service_terms'] != null &&
              translations['privacy_terms'] != null &&
              translations['location_terms'] != null) {
            currentLabels = {
              "terms_agreement": translations['terms_agreement'][currentCountryCode] ?? "이용약관 동의",
              "agree_all": translations['agree_all'][currentCountryCode] ?? "모든 약관에 동의",
              "service_terms": translations['service_terms'][currentCountryCode] ?? "[필수] 서비스 이용약관",
              "privacy_terms": translations['privacy_terms'][currentCountryCode] ?? "[필수] 개인정보수집/이용동의",
              "location_terms": translations['location_terms'][currentCountryCode] ?? "[필수] 위치기반 서비스 이용약관 동의",
            };
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading translations: $e');
    }
  }

  void _showTermsDetail(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const SingleChildScrollView(
          child: Text(
            '이용약관 내용은 추후 추가될 예정입니다.\n\n'
                '본 약관은 귀하의 서비스 이용에 관한 권리, 의무 및 책임사항을 규정합니다.',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentLabels['terms_agreement']!,
              style: const TextStyle(
                color: Color(0xFF353535),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildTermItem(
              isAll: true,
              title: currentLabels['agree_all']!,
              isAgreed: widget.controller.allTermsAgreedNotifier,
              onChanged: (value) {
                widget.controller.allTermsAgreed = value ?? false;
                // 모든 약관 체크박스 상태를 전체 체크박스와 동일하게 설정
                widget.controller.serviceTermsAgreed = value ?? false;
                widget.controller.privacyTermsAgreed = value ?? false;
                widget.controller.locationTermsAgreed = value ?? false;
              },
              showDivider: true,
            ),
            _buildTermItem(
              title: currentLabels['service_terms']!,
              isAgreed: widget.controller.serviceTermsAgreedNotifier,
              onChanged: (value) => widget.controller.serviceTermsAgreed = value ?? false,
              onTap: () => _showTermsDetail(currentLabels['service_terms']!),
            ),
            _buildTermItem(
              title: currentLabels['privacy_terms']!,
              isAgreed: widget.controller.privacyTermsAgreedNotifier,
              onChanged: (value) => widget.controller.privacyTermsAgreed = value ?? false,
              onTap: () => _showTermsDetail(currentLabels['privacy_terms']!),
            ),
            _buildTermItem(
              title: currentLabels['location_terms']!,
              isAgreed: widget.controller.locationTermsAgreedNotifier,
              onChanged: (value) => widget.controller.locationTermsAgreed = value ?? false,
              onTap: () => _showTermsDetail(currentLabels['location_terms']!),
              showBottomPadding: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermItem({
    required String title,
    required ValueNotifier<bool> isAgreed,
    required Function(bool?) onChanged,
    bool isAll = false,
    Function()? onTap,
    bool showDivider = false,
    bool showBottomPadding = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: showBottomPadding ? 4.0 : 0.0),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: ValueListenableBuilder<bool>(
                  valueListenable: isAgreed,
                  builder: (context, agreed, _) {
                    return Checkbox(
                      value: agreed,
                      onChanged: onChanged,
                      activeColor: const Color(0xFF3182F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                      side: const BorderSide(
                        color: Color(0xFFE5E5E5),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isAll ? const Color(0xFF353535) : const Color(0xFF666666),
                    fontSize: 12,
                    fontWeight: isAll ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (onTap != null)
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Color(0xFF999999), size: 20),
                  onPressed: onTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
        if (showDivider)
          Column(
            children: const [
              Divider(height: 1, color: Color(0xFFE5E5E5)),
              SizedBox(height: 12.0), // 디바이더 아래 여백 추가
            ],
          ),
      ],
    );
  }
}
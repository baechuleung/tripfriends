import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
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

  void _showTermsDetail(String type) {
    String pdfPath;
    String title;

    switch (type) {
      case 'service':
        pdfPath = 'assets/data/pdf/service_terms.pdf';
        title = currentLabels['service_terms']!;
        break;
      case 'privacy':
        pdfPath = 'assets/data/pdf/privacy_terms.pdf';
        title = currentLabels['privacy_terms']!;
        break;
      case 'location':
        pdfPath = 'assets/data/pdf/location_terms.pdf';
        title = currentLabels['location_terms']!;
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            color: Colors.white,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
              maxWidth: MediaQuery.of(context).size.width * 0.95,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFE5E5E5),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF353535),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: SfPdfViewer.asset(
                      pdfPath,
                      canShowScrollHead: false,
                      canShowScrollStatus: false,
                      enableDoubleTapZooming: true,
                      pageSpacing: 0,
                      canShowPaginationDialog: false,
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3182F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                fontFamily: 'Spoqa Han Sans Neo',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFFF2F3F7),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildTermItem(
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
                  showDivider: false,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildTermItem(
              title: currentLabels['service_terms']!,
              isAgreed: widget.controller.serviceTermsAgreedNotifier,
              onChanged: (value) => widget.controller.serviceTermsAgreed = value ?? false,
              onTap: () => _showTermsDetail('service'),
            ),
            _buildTermItem(
              title: currentLabels['privacy_terms']!,
              isAgreed: widget.controller.privacyTermsAgreedNotifier,
              onChanged: (value) => widget.controller.privacyTermsAgreed = value ?? false,
              onTap: () => _showTermsDetail('privacy'),
            ),
            _buildTermItem(
              title: currentLabels['location_terms']!,
              isAgreed: widget.controller.locationTermsAgreedNotifier,
              onChanged: (value) => widget.controller.locationTermsAgreed = value ?? false,
              onTap: () => _showTermsDetail('location'),
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
          child: InkWell(
            onTap: () => onChanged(!isAgreed.value),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isAgreed,
                    builder: (context, agreed, _) {
                      return Container(
                        width: 20,
                        height: 20,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: ShapeDecoration(
                                  color: agreed ? const Color(0xFF3182F6) : Colors.transparent,
                                  shape: OvalBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: agreed ? const Color(0xFF3182F6) : const Color(0xFFE4E4E4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (agreed)
                              const Center(
                                child: Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              )
                            else
                              const Center(
                                child: Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Color(0xFFE4E4E4),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isAll ? const Color(0xFF4E5968) : const Color(0xFF666666),
                      fontSize: isAll ? 14 : 12,
                      fontFamily: isAll ? 'Spoqa Han Sans Neo' : null,
                      fontWeight: isAll ? FontWeight.w700 : FontWeight.w500,
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
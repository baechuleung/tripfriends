import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../controller/detail/register_detail_controller.dart';
import '../../../../main.dart';

class Languages extends StatefulWidget {
  final RegisterDetailController controller;

  const Languages({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<Languages> createState() => _LanguagesState();
}

class _LanguagesState extends State<Languages> {
  Map<String, String> currentLabels = {
    "available_languages": "사용 가능 언어",
    "korean": "한국어",
    "japanese": "일본어",
    "english": "영어",
    "vietnamese": "베트남어",
    "chinese": "중국어",
    "thai": "태국어",
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

      setState(() {
        final translations = translationData['translations'];

        final availableLanguages = translations['available_languages'];
        final korean = translations['korean'];
        final japanese = translations['japanese'];
        final english = translations['english'];
        final vietnamese = translations['vietnamese'];
        final chinese = translations['chinese'];
        final thai = translations['thai'];

        if (availableLanguages != null && korean != null && japanese != null &&
            english != null && vietnamese != null && chinese != null && thai != null) {
          currentLabels = {
            "available_languages": availableLanguages[currentCountryCode],
            "korean": korean[currentCountryCode],
            "japanese": japanese[currentCountryCode],
            "english": english[currentCountryCode],
            "vietnamese": vietnamese[currentCountryCode],
            "chinese": chinese[currentCountryCode],
            "thai": thai[currentCountryCode],
          };
        }
      });
    } catch (e) {
      debugPrint('Error loading translations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentLabels['available_languages'] ?? '사용 가능 언어',
              style: TextStyle(
                color: const Color(0xFF353535),
                fontSize: 14,
                fontFamily: 'Spoqa Han Sans Neo',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<List<String>>(
              valueListenable: widget.controller.selectedLanguagesNotifier,
              builder: (context, selectedLanguages, _) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildLanguageCheckbox(
                            label: currentLabels['korean'] ?? '한국어',
                            value: selectedLanguages.contains('korean'),
                            onChanged: (value) => _handleLanguageSelection('korean', value),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildLanguageCheckbox(
                            label: currentLabels['japanese'] ?? '일본어',
                            value: selectedLanguages.contains('japanese'),
                            onChanged: (value) => _handleLanguageSelection('japanese', value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildLanguageCheckbox(
                            label: currentLabels['english'] ?? '영어',
                            value: selectedLanguages.contains('english'),
                            onChanged: (value) => _handleLanguageSelection('english', value),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildLanguageCheckbox(
                            label: currentLabels['vietnamese'] ?? '베트남어',
                            value: selectedLanguages.contains('vietnamese'),
                            onChanged: (value) => _handleLanguageSelection('vietnamese', value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildLanguageCheckbox(
                            label: currentLabels['chinese'] ?? '중국어',
                            value: selectedLanguages.contains('chinese'),
                            onChanged: (value) => _handleLanguageSelection('chinese', value),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildLanguageCheckbox(
                            label: currentLabels['thai'] ?? '태국어',
                            value: selectedLanguages.contains('thai'),
                            onChanged: (value) => _handleLanguageSelection('thai', value),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCheckbox({
    required String label,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return SizedBox(
      height: 35,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              child: value
                  ? Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF3182F6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
                  : Container(
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: Color(0xFFE4E4E4),
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: const Color(0xFF4E5968),
                  fontSize: 14,
                  fontFamily: 'Spoqa Han Sans Neo',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLanguageSelection(String language, bool? value) {
    if (value == true) {
      if (!widget.controller.selectedLanguagesNotifier.value.contains(language)) {
        final List<String> updatedLanguages = [...widget.controller.selectedLanguagesNotifier.value, language];
        widget.controller.selectedLanguagesNotifier.value = updatedLanguages;
      }
    } else {
      final List<String> updatedLanguages = widget.controller.selectedLanguagesNotifier.value
          .where((l) => l != language)
          .toList();
      widget.controller.selectedLanguagesNotifier.value = updatedLanguages;
    }
  }
}
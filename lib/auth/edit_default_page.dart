import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'controller/default/edit_default_controller.dart';
import 'components/default/profile.dart';
import 'components/default/name.dart';
import 'components/default/age.dart';
import 'components/default/nationality.dart';
import 'components/default/city.dart';
import 'components/default/gender.dart';
import 'components/default/terms_agreement.dart';
import 'components/default/phone_input.dart' show PhoneInput;
import '../main.dart';

class EditDefaultPage extends StatefulWidget {
  final String uid;

  const EditDefaultPage({
    super.key,
    required this.uid,
  });

  @override
  _EditDefaultPageState createState() => _EditDefaultPageState();
}

class _EditDefaultPageState extends State<EditDefaultPage> {
  late final EditDefaultController _controller;
  bool isLoading = false;
  bool isDataLoaded = false;

  Map<String, String> currentLabels = {
    "save": "저장하기",
    "edit_profile": "프로필 수정",
  };

  @override
  void initState() {
    super.initState();
    print('🏁 EditDefaultPage initState 시작');

    _controller = EditDefaultController(
      uid: widget.uid,
      onDataLoaded: _onDataLoaded,
    );

    _controller.isRegisteringNotifier.addListener(_updateLoadingState);
    _controller.isAllFieldsFilled.addListener(_checkButtonState);

    // 데이터 로드
    loadTranslations();

    print('✅ EditDefaultPage initState 완료');
  }

  // 데이터 로드 완료 시 호출되는 콜백
  void _onDataLoaded() {
    if (mounted) {
      setState(() {
        isDataLoaded = true;
        print('🔄 데이터 로드 완료 - UI 업데이트');

        // 각 컨트롤러의 번역 로드
        _loadControllersTranslations();
      });
    }
  }

  // 각 컨트롤러의 번역을 로드하는 메서드
  void _loadControllersTranslations() {
    // 각 컨트롤러의 번역 로드
    _controller.nameController.loadTranslations(currentCountryCode);
    _controller.ageController.loadTranslations(currentCountryCode);
    _controller.genderController.loadTranslations(currentCountryCode);
    _controller.nationalityController.loadTranslations(currentCountryCode);
    _controller.cityController.loadTranslations(currentCountryCode);
    _controller.phoneController.loadTranslations(currentCountryCode);
    _controller.profileController.loadTranslations(currentCountryCode);
    _controller.termsAgreementController.loadTranslations(currentCountryCode);

    print('🌐 모든 컨트롤러 번역 로드 완료');
  }

  void _updateLoadingState() {
    if (mounted) {
      setState(() {
        isLoading = _controller.isRegisteringNotifier.value;
        print('🔄 로딩 상태 업데이트: $isLoading');
      });
    }
  }

  void _checkButtonState() {
    if (mounted) {
      setState(() {
        print('🔘 버튼 상태 업데이트: ${_controller.isAllFieldsFilled.value}');
      });
    }
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  Future<void> loadTranslations() async {
    if (!mounted) return;
    try {
      print('🌐 번역 데이터 로드 시작');
      final String translationJson = await rootBundle.loadString('assets/data/auth_translations.json');
      final translationData = json.decode(translationJson);
      final translations = translationData['translations'];

      setState(() {
        currentLabels.forEach((key, _) {
          if (translations[key] != null) {
            currentLabels[key] = translations[key][currentCountryCode] ??
                translations[key]['KR'] ??
                currentLabels[key];
          }
        });
        print('✅ 번역 데이터 로드 완료');
      });
    } catch (e) {
      print('❌ 번역 데이터 로드 오류: $e');
      debugPrint('Error loading translations: $e');
    }
  }

  Future<void> _handleSaveButton() async {
    if (!mounted) return;
    try {
      print('💾 저장 버튼 클릭');
      setState(() {
        isLoading = true;
      });

      await _controller.saveProfileToFirestore();
      print('✅ 프로필 수정이 완료되었습니다.');

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('❌ 수정 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🔄 EditDefaultPage 빌드 시작 - 데이터 로드됨: $isDataLoaded, 버튼 활성화: ${_controller.isAllFieldsFilled.value}');

    return Stack(
      children: [
        GestureDetector(
          onTap: _dismissKeyboard,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                currentLabels['edit_profile'] ?? '프로필 수정',
                style: const TextStyle(
                  color: Color(0xFF353535),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            body: isDataLoaded
                ? _buildFormContent()
                : const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF3182F6),
              ),
            ),
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: Material(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFormContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Profile(controller: _controller.profileController),
            const SizedBox(height: 16),
            Name(controller: _controller.nameController),
            const SizedBox(height: 16),
            Gender(controller: _controller.genderController),
            const SizedBox(height: 16),
            Age(controller: _controller.ageController),
            const SizedBox(height: 16),
            Nationality(controller: _controller.nationalityController),
            const SizedBox(height: 16),
            City(controller: _controller.cityController),
            const SizedBox(height: 16),
            PhoneInput(controller: _controller.phoneController),
            const SizedBox(height: 16),
            TermsAgreement(controller: _controller.termsAgreementController),
            const SizedBox(height: 32),
            ValueListenableBuilder<bool>(
              valueListenable: _controller.isAllFieldsFilled,
              builder: (context, fieldsAreFilled, _) {
                print('🔘 버튼 상태 빌더: $fieldsAreFilled');
                return ValueListenableBuilder<bool>(
                  valueListenable: _controller.isRegisteringNotifier,
                  builder: (context, isRegistering, _) {
                    final buttonEnabled = fieldsAreFilled && !isRegistering;
                    print('🔘 버튼 최종 활성화 상태: $buttonEnabled');

                    return SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: buttonEnabled ? _handleSaveButton : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3182F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          disabledBackgroundColor: const Color(0xFFE5E5E5),
                        ),
                        child: isRegistering
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          currentLabels['save'] ?? "저장하기",
                          style: TextStyle(
                            color: fieldsAreFilled ? Colors.white : const Color(0xFF999999),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('🏁 EditDefaultPage dispose 호출');
    _controller.isRegisteringNotifier.removeListener(_updateLoadingState);
    _controller.isAllFieldsFilled.removeListener(_checkButtonState);
    _controller.dispose();
    super.dispose();
  }
}
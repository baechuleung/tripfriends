import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../main.dart';
import 'controller/default/register_controller.dart';
import 'components/default/profile.dart';
import 'components/default/name.dart';
import 'components/default/age.dart';
import 'components/default/nationality.dart';
import 'components/default/city.dart';
import 'components/default/gender.dart';
import 'components/default/terms_agreement.dart';
import 'components/default/phone_input.dart' show PhoneInput;
import 'register_detail_page.dart';
import '../main_page.dart';
import '../services/shared_preferences_service.dart';

class RegisterPage extends StatefulWidget {
  final String uid;

  const RegisterPage({
    super.key,
    required this.uid,
  });

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final RegisterController _controller;
  bool isLoading = false;

  Map<String, String> currentLabels = {
    "next": "다음",
    "register": "회원가입",
  };

  @override
  void initState() {
    super.initState();
    // 등록 중임을 표시하는 플래그 설정
    SharedPreferencesService.setBool('is_registering', true);

    _controller = RegisterController(
      uid: widget.uid,
    );
    loadTranslations();
    _controller.isRegisteringNotifier.addListener(_updateLoadingState);
  }

  void _updateLoadingState() {
    if (mounted) {
      setState(() {
        isLoading = _controller.isRegisteringNotifier.value;
      });
    }
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  Future<void> loadTranslations() async {
    if (!mounted) return;
    try {
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
      });
    } catch (e) {
      debugPrint('Error loading translations: $e');
    }
  }

  Future<void> _handleNextButton() async {
    if (!mounted) return;
    try {
      setState(() {
        isLoading = true;
      });

      await _controller.registerToFirestore();
      print('✅ 프렌즈 등록이 완료되었습니다.');

      // 등록이 완료되면 플래그 해제
      await SharedPreferencesService.removeBool('is_registering');

      if (mounted) {
        // pushReplacement 대신 push 사용
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterDetailPage(uid: widget.uid),
          ),
        );
      }
    } catch (e) {
      print('❌ 등록 실패: $e');
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
    return Stack(
      children: [
        GestureDetector(
          onTap: _dismissKeyboard,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF353535)),
                onPressed: () {
                  // 뒤로 가기 시 플래그 해제
                  SharedPreferencesService.removeBool('is_registering');
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const MainPage()),
                  );
                },
              ),
              centerTitle: true,
              title: Text(
                currentLabels['register'] ?? '회원가입',
                style: const TextStyle(
                  color: Color(0xFF353535),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Profile(controller: _controller.profileController),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TermsAgreement(controller: _controller.termsAgreementController),
                    const SizedBox(height: 32),
                    ValueListenableBuilder<bool>(
                      valueListenable: _controller.isAllFieldsFilled,
                      builder: (context, allFieldsFilled, _) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: _controller.isRegisteringNotifier,
                          builder: (context, isRegistering, _) {
                            return SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton(
                                onPressed: (allFieldsFilled && !isRegistering)
                                    ? _handleNextButton
                                    : null,
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
                                  currentLabels['next'] ?? "다음",
                                  style: TextStyle(
                                    color: allFieldsFilled
                                        ? Colors.white
                                        : const Color(0xFF999999),
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

  @override
  void dispose() {
    // 플래그 해제
    SharedPreferencesService.removeBool('is_registering');

    _controller.isRegisteringNotifier.removeListener(_updateLoadingState);
    _controller.dispose();
    super.dispose();
  }
}
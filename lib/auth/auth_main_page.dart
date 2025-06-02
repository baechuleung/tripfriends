import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../services/shared_preferences_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 추가
import 'google/google_auth_service.dart';
import 'apple/apple_auth_service.dart';
import 'facebook/facebook_auth_service.dart';
import 'email/email_login_page.dart';
import 'register_page.dart';
import 'loading_spinner.dart'; // 로딩 스피너 추가

class AuthMainPageWidget extends StatefulWidget {
  const AuthMainPageWidget({super.key});

  @override
  State<AuthMainPageWidget> createState() => _AuthMainPageWidgetState();
}

class _AuthMainPageWidgetState extends State<AuthMainPageWidget> {
  Map<String, String> currentLabels = {};

  @override
  void initState() {
    super.initState();
    loadTranslations();
  }

  // 사용자 세션 저장 함수 수정
  Future<void> _saveUserSession(String uid, bool isNewUser) async {
    try {
      if (!isNewUser) {
        // 기존 사용자인 경우, Firestore에서 사용자 정보 가져오기
        final userDoc = await FirebaseFirestore.instance
            .collection('tripfriends_users')
            .doc(uid)
            .get();

        if (userDoc.exists) {
          // 사용자 정보가 있으면 세션에 저장
          Map<String, dynamic>? userData = userDoc.data();

          // 세션 저장
          await SharedPreferencesService.saveUserSession(
            uid,
            userDoc: userData,
          );
          debugPrint('✅ 로그인 성공: 세션 정보 저장 완료');
        } else {
          // 사용자 정보가 없으면 기본 정보만 저장
          await SharedPreferencesService.saveUserSession(uid);
          debugPrint('⚠️ 로그인: Firestore에 사용자 정보가 없음, 기본 정보만 저장');
        }
      } else {
        // 신규 사용자인 경우, 기본 정보만 저장
        await SharedPreferencesService.saveUserSession(uid);
        debugPrint('✅ 신규 사용자 로그인: 기본 정보 저장');
      }

      // 로그인 상태 설정
      await SharedPreferencesService.setLoggedIn(true);
    } catch (e) {
      debugPrint('⚠️ 세션 저장 중 오류: $e');
      // 오류가 발생해도 로그인 상태는 설정
      await SharedPreferencesService.setLoggedIn(true);
    }
  }

  Future<void> loadTranslations() async {
    try {
      final String translationsJson = await rootBundle.loadString('assets/data/translations.json');
      final Map<String, dynamic> translationData = json.decode(translationsJson);

      // 수정된 부분: String? 타입 처리 추가
      String currentLanguage = SharedPreferencesService.getLanguage() ?? 'KR';
      debugPrint('🌐 번역에 사용할 언어 코드: $currentLanguage');

      if (mounted && translationData.containsKey('translations')) {
        final Map<String, dynamic> translationsMap = translationData['translations'];
        final Map<String, String> krToTranslated = {};

        translationsMap.forEach((key, value) {
          if (value is Map && value.containsKey('KR') && value.containsKey(currentLanguage)) {
            final String krText = value['KR'];
            final String translatedText = value[currentLanguage];
            krToTranslated[krText] = translatedText;
          }
        });

        setState(() {
          currentLabels = krToTranslated;
        });
      }
    } catch (e) {
      debugPrint('❌ 번역 로딩 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF774CFF),
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 중앙에 main_title.png 이미지 배치
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    'assets/main_title.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // 하단 로그인 버튼들
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildSocialButton("Google Login", "assets/icons/google.png", Colors.white, Colors.black, () async {
                  // 로딩 스피너 표시
                  LoadingSpinner.show(context);

                  final result = await GoogleAuthService().signInWithGoogle();

                  // 로딩 스피너 숨기기
                  LoadingSpinner.hide();

                  if (result != null) {
                    final userCredential = result['userCredential'];
                    final isNewUser = result['isNewUser'] as bool;
                    final uid = userCredential.user!.uid;

                    // 세션 저장 (추가된 부분)
                    await _saveUserSession(uid, isNewUser);

                    if (!mounted) return;
                    if (isNewUser) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterPage(
                            uid: uid,
                          ),
                        ),
                            (route) => false, // 모든 이전 라우트 제거
                      );
                    } else {
                      // 이전 화면들을 모두 제거하고 메인 페이지로 이동
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/main',
                            (route) => false, // 모든 이전 라우트 제거
                      );
                    }
                  }
                }),
                buildSocialButton("Apple Login", "assets/icons/apple.png", Colors.white, Colors.black, () async {
                  // 로딩 스피너 표시
                  LoadingSpinner.show(context);

                  final result = await AppleAuthService().signInWithApple();

                  // 로딩 스피너 숨기기
                  LoadingSpinner.hide();

                  if (result != null) {
                    final userCredential = result['userCredential'];
                    final isNewUser = result['isNewUser'] as bool;
                    final uid = userCredential.user!.uid;

                    // 세션 저장 (추가된 부분)
                    await _saveUserSession(uid, isNewUser);

                    if (!mounted) return;
                    if (isNewUser) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterPage(
                            uid: uid,
                          ),
                        ),
                            (route) => false, // 모든 이전 라우트 제거
                      );
                    } else {
                      // 이전 화면들을 모두 제거하고 메인 페이지로 이동
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/main',
                            (route) => false, // 모든 이전 라우트 제거
                      );
                    }
                  }
                }),
                buildSocialButton("Facebook Login", "assets/icons/facebook.png", Colors.white, Colors.black, () async {
                  // 로딩 스피너 표시
                  LoadingSpinner.show(context);

                  final result = await FacebookAuthService().signInWithFacebook();

                  // 로딩 스피너 숨기기
                  LoadingSpinner.hide();

                  if (result != null) {
                    final userCredential = result['userCredential'];
                    final isNewUser = result['isNewUser'] as bool;
                    final uid = userCredential.user!.uid;

                    // 세션 저장 (추가된 부분)
                    await _saveUserSession(uid, isNewUser);

                    if (!mounted) return;
                    if (isNewUser) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterPage(
                            uid: uid,
                          ),
                        ),
                            (route) => false, // 모든 이전 라우트 제거
                      );
                    } else {
                      // 이전 화면들을 모두 제거하고 메인 페이지로 이동
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/main',
                            (route) => false, // 모든 이전 라우트 제거
                      );
                    }
                  }
                }),
                // 이메일 로그인 버튼 추가
                buildSocialButton("Email Login", "assets/icons/email.png", Colors.white, Colors.black, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EmailLoginPage()),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSocialButton(String text, String assetPath, Color bgColor, Color textColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Image.asset(
                assetPath,
                width: 24,
                height: 24,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  currentLabels[text] ?? text,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 48), // 오른쪽 여백을 위해 추가
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../services/shared_preferences_service.dart';
import '../../main_page.dart';
import '../register_page.dart';
import 'email_auth_service.dart';
import 'email_register_page.dart';
import 'forgot_password_page.dart';
import '../../services/translation_service.dart'; // 번역 서비스 import 추가

class EmailLoginPage extends StatefulWidget {
  const EmailLoginPage({super.key});

  @override
  State<EmailLoginPage> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailAuthService = EmailAuthService();
  final _translationService = TranslationService(); // 번역 서비스 인스턴스 추가
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _translationService.init(); // 번역 서비스 초기화
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('📱 로그인 시도: ${_emailController.text.trim()}');
      final result = await _emailAuthService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (result != null) {
        final userCredential = result['userCredential'];
        final isNewUser = result['isNewUser'] as bool;
        SharedPreferencesService.setLoggedIn(true);
        debugPrint('✅ 로그인 성공: ${userCredential.user!.uid}, 신규유저: $isNewUser');

        if (!mounted) return;
        if (isNewUser) {
          debugPrint('🔄 신규유저: 회원가입 페이지로 이동');

          // 회원가입 페이지로 이동 시 네비게이션 스택 초기화
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => RegisterPage(
                uid: userCredential.user!.uid,
              ),
            ),
                (route) => false, // 모든 이전 라우트 제거
          );
        } else {
          debugPrint('🔄 기존유저: 메인 페이지로 이동');

          // 메인 페이지로 이동 시 네비게이션 스택 초기화
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/main',
                (route) => false, // 모든 이전 라우트 제거
          );
        }
      }
    } catch (e) {
      // UI에 오류 메시지를 표시하지 않고 로그만 출력
      debugPrint('❌ 로그인 오류: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _translationService.get('email_login_title', '이메일 로그인'),
            style: const TextStyle(
              color: Color(0xFF353535),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                // 본문의 '이메일 로그인' 텍스트 제거함
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: _translationService.get('email_label', '이메일'),
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return _translationService.get('email_required', '이메일을 입력해주세요');
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return _translationService.get('email_invalid', '유효한 이메일 주소를 입력해주세요');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: _translationService.get('password_label', '비밀번호'),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return _translationService.get('password_required', '비밀번호를 입력해주세요');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: Text(_translationService.get('forgot_password', '비밀번호를 잊으셨나요?')),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    _translationService.get('login_button', '로그인'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_translationService.get('no_account', '계정이 없으신가요?')),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmailRegisterPage(),
                          ),
                        );
                      },
                      child: Text(_translationService.get('register', '회원가입')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
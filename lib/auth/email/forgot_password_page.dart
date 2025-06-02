import 'package:flutter/material.dart';
import 'email_auth_service.dart';
import '../../services/translation_service.dart'; // 번역 서비스 import 추가

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailAuthService = EmailAuthService();
  final _translationService = TranslationService(); // 번역 서비스 인스턴스 추가
  bool _isLoading = false;
  String? _errorMessage;
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    _translationService.init(); // 번역 서비스 초기화
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _emailSent = false;
    });

    try {
      await _emailAuthService.sendPasswordResetEmail(_emailController.text.trim());
      setState(() {
        _emailSent = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
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
      // 빈 공간을 탭하면 키보드가 닫히도록 함
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _translationService.get('forgot_password_title', '비밀번호 재설정'),
            style: const TextStyle(
              color: Color(0xFF353535),
              fontSize: 14,
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
                // 본문의 '비밀번호 재설정' 텍스트 제거함
                const SizedBox(height: 16),
                Text(
                  _translationService.get('forgot_password_description',
                      '가입한 이메일 주소를 입력하시면, 비밀번호 재설정 링크를 보내드립니다.'),
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
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
                if (_emailSent) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          _translationService.get('reset_email_sent', '비밀번호 재설정 이메일이 발송되었습니다.'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _translationService.get('reset_email_instruction', '이메일 내의 링크를 클릭하여 비밀번호를 재설정하세요.'),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
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
                    _translationService.get('send_reset_link', '비밀번호 재설정 링크 보내기'),
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
                    Text(_translationService.get('remember_password', '비밀번호가 기억나셨나요?')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(_translationService.get('back_to_login', '로그인으로 돌아가기')),
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
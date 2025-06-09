import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/shared_preferences_service.dart';
import '../translations/translation_service.dart'; // 번역 서비스 경로 변경
import '../main_page.dart';
import '../main.dart'; // currentCountryCode 접근용

class AccountDeletePage extends StatefulWidget {
  const AccountDeletePage({Key? key}) : super(key: key);

  @override
  State<AccountDeletePage> createState() => _AccountDeletePageState();
}

class _AccountDeletePageState extends State<AccountDeletePage> {
  bool _isChecked = false;
  bool _isLoading = false;
  late TranslationService _translationService;

  @override
  void initState() {
    super.initState();
    _translationService = TranslationService();
  }

  // 현재 언어로 번역 가져오기
  String _t(String key) {
    return _translationService.getTranslation(key, currentCountryCode);
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_t('delete_account')),
          content: Text(_t('delete_confirm_message')),
          actions: <Widget>[
            TextButton(
              child: Text(_t('cancel')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                _t('delete'),
                style: const TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String uid = user.uid;

        // 백엔드 API 호출하여 계정 삭제 요청
        final success = await _requestTripfriendsUserDeletion(uid);

        if (success) {
          // 백엔드에서 성공적으로 계정을 삭제한 경우
          // 로컬에서 로그아웃 처리만 수행
          await SharedPreferencesService.logout();
          await FirebaseAuth.instance.signOut();

          // 로딩 상태 해제
          setState(() {
            _isLoading = false;
          });

          if (!mounted) return;

          // 성공 메시지 디버그 프린트
          debugPrint('✅ ${_t('delete_success')}');

          // 메인 페이지로 이동 (로그인 화면으로)
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainPage()),
                (Route<dynamic> route) => false,
          );
        } else {
          // 삭제 요청은 실패했지만 로그아웃은 진행
          await SharedPreferencesService.logout();
          await FirebaseAuth.instance.signOut();

          setState(() {
            _isLoading = false;
          });

          if (!mounted) return;

          // 실패 메시지 디버그 프린트
          debugPrint('⚠️ ${_t('delete_partial')}');

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainPage()),
                (Route<dynamic> route) => false,
          );
        }
      }
    } catch (error) {
      // 로딩 상태 해제
      setState(() {
        _isLoading = false;
      });

      // 에러 메시지 디버그 프린트
      debugPrint('🚫 ${_t('delete_error')}: ${error.toString()}');
    }
  }

  // 백엔드에 트립프렌즈 사용자 계정 삭제 요청
  Future<bool> _requestTripfriendsUserDeletion(String uid) async {
    try {
      // 백엔드 API 엔드포인트
      const String apiUrl = 'https://us-central1-tripjoy-d309f.cloudfunctions.net/main/delete-tripfriends-user';

      debugPrint('🔄 계정 삭제 API 호출 시작: $uid');

      // HTTP 요청 전송
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': uid,
        }),
      );

      // 응답 확인
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          debugPrint('✅ 계정 삭제 요청 성공: ${responseData['message']}');
          return true;
        } else {
          debugPrint('⚠️ 계정 삭제 요청 실패: ${responseData['message']}');
          return false;
        }
      } else {
        debugPrint('⚠️ 계정 삭제 API 응답 오류: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('⚠️ 계정 삭제 API 호출 오류: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _t('delete_account'),
          style: const TextStyle(
            color: Color(0xFF353535),
            fontSize: 16,
            fontFamily: 'Spoqa Han Sans Neo',
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.only(left: 8, right: 8, top: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('delete_check'),
                  style: const TextStyle(
                    color: Color(0xFF353535),
                    fontSize: 18,
                    fontFamily: 'Spoqa Han Sans Neo',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                _buildWarningCard(),
                const SizedBox(height: 32),
                _buildAgreementCheckbox(),
                const SizedBox(height: 40),
                _buildDeleteButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWarningCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _t('delete_warning'),
          style: const TextStyle(
            color: Color(0xFF4E5968),
            fontSize: 14,
            fontFamily: 'Spoqa Han Sans Neo',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ${_t('delete_warning_1')}',
                style: const TextStyle(
                  color: Color(0xFF353535),
                  fontSize: 14,
                  fontFamily: 'Spoqa Han Sans Neo',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '• ${_t('delete_warning_2')}',
                style: const TextStyle(
                  color: Color(0xFF353535),
                  fontSize: 14,
                  fontFamily: 'Spoqa Han Sans Neo',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '• ${_t('delete_warning_3')}',
                style: const TextStyle(
                  color: Color(0xFF353535),
                  fontSize: 14,
                  fontFamily: 'Spoqa Han Sans Neo',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '• ${_t('delete_warning_4')}',
                style: const TextStyle(
                  color: Color(0xFF353535),
                  fontSize: 14,
                  fontFamily: 'Spoqa Han Sans Neo',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '• ${_t('delete_warning_5')}',
                style: const TextStyle(
                  color: Color(0xFF353535),
                  fontSize: 14,
                  fontFamily: 'Spoqa Han Sans Neo',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAgreementCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isChecked = !_isChecked;
            });
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _isChecked ? const Color(0xFF5A7EF5) : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _isChecked ? const Color(0xFF5A7EF5) : const Color(0xFFE0E0E0),
                width: 1.5,
              ),
            ),
            child: _isChecked
                ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 16,
            )
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _t('delete_agreement'),
            style: const TextStyle(
              color: Color(0xFF353535),
              fontSize: 14,
              fontFamily: 'Spoqa Han Sans Neo',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 45,
            decoration: ShapeDecoration(
              color: const Color(0xFFE8F2FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(5),
              child: Center(
                child: Text(
                  _t('cancel'),
                  style: const TextStyle(
                    color: Color(0xFF3182F6),
                    fontSize: 14,
                    fontFamily: 'Spoqa Han Sans Neo',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 45,
            decoration: ShapeDecoration(
              color: _isChecked ? const Color(0xFFFFE8E8) : const Color(0xFFE0E0E0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
            child: InkWell(
              onTap: _isChecked ? _showDeleteConfirmationDialog : null,
              borderRadius: BorderRadius.circular(5),
              child: Center(
                child: Text(
                  _t('delete_account'),
                  style: TextStyle(
                    color: _isChecked ? const Color(0xFFFF5050) : const Color(0xFF999999),
                    fontSize: 14,
                    fontFamily: 'Spoqa Han Sans Neo',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
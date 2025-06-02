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
        title: Text(_t('delete_account')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t('delete_check'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildWarningCard(),
              const SizedBox(height: 24),
              _buildAgreementCheckbox(),
              const SizedBox(height: 32),
              _buildDeleteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('delete_warning'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('• ${_t('delete_warning_1')}'),
          Text('• ${_t('delete_warning_2')}'),
          Text('• ${_t('delete_warning_3')}'),
          Text('• ${_t('delete_warning_4')}'),
          Text('• ${_t('delete_warning_5')}'),
        ],
      ),
    );
  }

  Widget _buildAgreementCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _isChecked,
          onChanged: (value) {
            setState(() {
              _isChecked = value ?? false;
            });
          },
        ),
        Expanded(
          child: Text(_t('delete_agreement')),
        ),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isChecked ? _showDeleteConfirmationDialog : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          disabledBackgroundColor: Colors.grey,
        ),
        child: Text(
          _t('delete_account'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
// features/profile/widgets/logged_in_profile.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../main.dart';
import '../../../auth/edit_default_page.dart';
import '../services/auth_service.dart';
import '../utils/profile_translation.dart';
import '../services/profile_media_service.dart';
import 'profile_media_slider.dart';

class LoggedInProfileWidget extends StatefulWidget {
  const LoggedInProfileWidget({super.key});

  @override
  State<LoggedInProfileWidget> createState() => _LoggedInProfileWidgetState();
}

class _LoggedInProfileWidgetState extends State<LoggedInProfileWidget> {
  Map<String, String> currentLabels = ProfileTranslation.defaultLabels;
  String? lastCountryCode;
  late Stream<DocumentSnapshot> _stream;
  int _userPoint = 0;
  late Map<String, dynamic> _userData = {};
  int _reviewCount = 0;
  ProfileMediaService? _mediaService;
  bool _isLoadingMedia = true;

  @override
  void initState() {
    super.initState();
    final user = AuthService.currentUser;
    if (user != null) {
      _stream = AuthService.tripfriendsStream(user.uid);
      _loadUserPoint(user.uid);
      _loadReviewCount(user.uid);

      // 미디어 서비스 초기화
      _mediaService = ProfileMediaService(
        onMediaLoadingStateChanged: (isLoading) {
          if (mounted) {
            setState(() {
              _isLoadingMedia = isLoading;
            });
          }
        },
      );

      // 다음 프레임에 미디어 로드 시작
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadProfileMedia(user.uid);
      });
    }
    loadTranslations();
  }

  // 미디어 로드 함수 추가 - 최적화
  void _loadProfileMedia(String uid) {
    try {
      // 현재 BuildContext 전달하여 이미지 프리캐싱 활성화
      _mediaService!.loadProfileMedia(uid, context);
    } catch (e) {
      print('미디어 로드 오류: $e');
      // 오류 발생 시, 빈 기본 이미지로 설정하여 UI에 적어도 뭔가 표시하도록 함
      if (mounted && _mediaService != null) {
        _mediaService!.setDefaultMedia({});
      }
    }
  }

  Future<void> _loadUserPoint(String userId) async {
    try {
      final point = await AuthService.getUserPoint(userId);
      if (mounted) {
        setState(() {
          _userPoint = point;
        });
      }
    } catch (e) {
      print('포인트 로드 오류: $e');
    }
  }

  Future<void> _loadReviewCount(String userId) async {
    try {
      final count = await AuthService.getUserReviewCount(userId);
      if (mounted) {
        setState(() {
          _reviewCount = count;
        });
      }
    } catch (e) {
      print('리뷰 카운트 로드 오류: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (lastCountryCode != currentCountryCode) {
      loadTranslations();
    }
  }

  @override
  void didUpdateWidget(LoggedInProfileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (lastCountryCode != currentCountryCode) {
      loadTranslations();
    }
  }

  @override
  void dispose() {
    _mediaService?.dispose();
    super.dispose();
  }

  Future<void> loadTranslations() async {
    try {
      final translations = await ProfileTranslation.loadTranslations(lastCountryCode);

      if (mounted) {
        setState(() {
          currentLabels = translations;
          lastCountryCode = currentCountryCode;
        });
      }
    } catch (e) {
      print('번역 로드 오류: $e');
    }
  }

  // 프로필 수정 페이지로 이동하는 메소드
  Future<void> _navigateToEditProfile(String uid) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDefaultPage(uid: uid),
      ),
    );

    // 수정 페이지에서 변경이 있었다면 UI 업데이트 (선택 사항)
    if (result == true && mounted) {
      setState(() {});
      _loadProfileMedia(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    if (user == null) {
      return const SizedBox();
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('오류가 발생했습니다: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data?.data() as Map<String, dynamic>?;
        if (data == null) {
          return const SizedBox();
        }

        _userData = data; // 사용자 데이터 저장

        // 스트림에서 최신 포인트 데이터 업데이트
        if (data.containsKey('point') && data['point'] != _userPoint) {
          _userPoint = data['point'] ?? 0;
        }

        return _buildProfileContent(context, user);
      },
    );
  }

  Widget _buildProfileContent(BuildContext context, User user) {
    final isApproved = _userData['isApproved'] ?? false;
    final approvalReason = _userData['approvalReason'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 프로필 이미지/비디오 슬라이더
        ProfileMediaSlider(
          isLoading: _isLoadingMedia,
          userData: _userData,
          mediaService: _mediaService,
          reviewCount: _reviewCount,
          currentLabels: currentLabels,
        ),

        const SizedBox(height: 16), // 슬라이더와 수정 버튼 사이 간격

        // 프로필 수정 버튼
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GestureDetector(
            onTap: () => _navigateToEditProfile(user.uid),
            child: Container(
              width: double.infinity,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: const Color(0xFFD9D9D9),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    currentLabels['edit'] ?? '프로필 수정',
                    style: TextStyle(
                      color: const Color(0xFF4E5968),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.edit,
                    size: 16,
                    color: const Color(0xFF4E5968),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 승인 대기 사유 표시 (승인 대기 상태이고 사유가 있을 때만)
        if (!isApproved && approvalReason != null && approvalReason.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    approvalReason,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
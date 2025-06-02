// features/profile/widgets/profile_widget.dart
import 'package:flutter/material.dart';
import '../../../services/shared_preferences_service.dart';
import 'logged_in_profile.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  @override
  void initState() {
    super.initState();
    SharedPreferencesService.validateAndCleanSession();
  }

  @override
  Widget build(BuildContext context) {
    // Firebase Auth 기준으로 로그인 상태 확인
    bool isLoggedIn = SharedPreferencesService.isLoggedIn();

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          if (isLoggedIn)
            const LoggedInProfileWidget()
        ],
      ),
    );
  }
}
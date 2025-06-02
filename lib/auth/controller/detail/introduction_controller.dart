import 'package:flutter/material.dart';

class IntroductionController {
  final TextEditingController introductionController = TextEditingController();

  bool get isEligibleForPoints =>
      introductionController.text.trim().length >= 300;

  void dispose() {
    introductionController.dispose();
  }
}
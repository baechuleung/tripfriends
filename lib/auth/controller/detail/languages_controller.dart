import 'package:flutter/material.dart';

class LanguagesController {
  final ValueNotifier<List<String>> selectedLanguagesNotifier = ValueNotifier<List<String>>([]);

  void handleLanguageSelection(String language, bool? value) {
    if (value == true) {
      if (!selectedLanguagesNotifier.value.contains(language)) {
        final List<String> updatedLanguages = [...selectedLanguagesNotifier.value, language];
        selectedLanguagesNotifier.value = updatedLanguages;
      }
    } else {
      final List<String> updatedLanguages = selectedLanguagesNotifier.value
          .where((l) => l != language)
          .toList();
      selectedLanguagesNotifier.value = updatedLanguages;
    }
  }

  void dispose() {
    selectedLanguagesNotifier.dispose();
  }
}
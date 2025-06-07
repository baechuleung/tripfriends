// lib/translations/components_translations.dart

class ComponentsTranslations {
  static String getTranslation(String key, String language) {
    return translations[key]?[language] ?? translations[key]?['KR'] ?? key;
  }

  static const Map<String, Map<String, String>> translations = {
    // LogoutPopup
    "logout_confirm_message": {
      "KR": "정말 로그아웃 하시겠습니까?",
      "VN": "Bạn có chắc chắn muốn đăng xuất không?",
      "JP": "本当にログアウトしますか？",
      "TH": "คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?",
      "PH": "Are you sure you want to logout?"
    },
    "cancel": {
      "KR": "취소",
      "VN": "Hủy",
      "JP": "キャンセル",
      "TH": "ยกเลิก",
      "PH": "Cancel"
    },
    "confirm": {
      "KR": "확인",
      "VN": "Xác nhận",
      "JP": "確認",
      "TH": "ยืนยัน",
      "PH": "Confirm"
    },
  };
}
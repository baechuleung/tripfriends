// lib/translations/version_translations.dart

class VersionTranslations {
  static String getTranslation(String key, String language) {
    return translations[key]?[language] ?? translations[key]?['KR'] ?? key;
  }

  static const Map<String, Map<String, String>> translations = {
    // Version Update Popup
    "force_update_title": {
      "KR": "필수 업데이트",
      "VN": "Cập nhật bắt buộc",
      "JP": "必須アップデート",
      "TH": "อัปเดตที่จำเป็น",
      "PH": "Required Update"
    },
    "new_version_available": {
      "KR": "새로운 버전 출시!",
      "VN": "Phiên bản mới đã ra mắt!",
      "JP": "新しいバージョンリリース！",
      "TH": "เวอร์ชันใหม่มาแล้ว!",
      "PH": "New version available!"
    },
    "default_update_message": {
      "KR": "더 나은 서비스를 위해\n최신 버전으로 업데이트해주세요.",
      "VN": "Vui lòng cập nhật lên phiên bản mới nhất\nđể có trải nghiệm tốt hơn.",
      "JP": "より良いサービスのため\n最新バージョンにアップデートしてください。",
      "TH": "กรุณาอัปเดตเป็นเวอร์ชันล่าสุด\nเพื่อการบริการที่ดีขึ้น",
      "PH": "Please update to the latest version\nfor better service."
    },
    "update_later": {
      "KR": "나중에",
      "VN": "Để sau",
      "JP": "後で",
      "TH": "ภายหลัง",
      "PH": "Later"
    },
    "update_now": {
      "KR": "지금 업데이트",
      "VN": "Cập nhật ngay",
      "JP": "今すぐアップデート",
      "TH": "อัปเดตตอนนี้",
      "PH": "Update Now"
    },
    "go_to_update": {
      "KR": "업데이트하러 가기",
      "VN": "Đi cập nhật",
      "JP": "アップデートしに行く",
      "TH": "ไปอัปเดต",
      "PH": "Go to Update"
    },
    "cannot_open_store": {
      "KR": "스토어를 열 수 없습니다.",
      "VN": "Không thể mở cửa hàng.",
      "JP": "ストアを開けません。",
      "TH": "ไม่สามารถเปิดร้านค้าได้",
      "PH": "Cannot open store."
    },
  };
}
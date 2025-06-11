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
    "home": {
      "KR": "홈",
      "VN": "Trang chủ",
      "JP": "ホーム",
      "TH": "หน้าแรก",
      "PH": "Home"
    },
    "reservation_list": {
      "KR": "예약목록",
      "VN": "Đang đặt",
      "JP": "予約一覧",
      "TH": "จองอยู่",
      "PH": "Ongoing"
    },
    "past_reservations": {
      "KR": "지난예약",
      "VN": "Đã đặt",
      "JP": "過去予約",
      "TH": "เก่าจอง",
      "PH": "History"
    },
    "chat_list": {
      "KR": "채팅 리스트",
      "VN": "Trò chuyện",
      "JP": "チャット",
      "TH": "รายการแชท",
      "PH": "Chat List"
    },
    "my_info": {
      "KR": "내정보",
      "VN": "Thông tin",
      "JP": "マイ情報",
      "TH": "ข้อมูลของฉัน",
      "PH": "My Info"
    },
    // Top Tab Bar
    "travel": {
      "KR": "여행",
      "VN": "Du lịch",
      "JP": "旅行",
      "TH": "ท่องเที่ยว",
      "PH": "Travel"
    },
    "job_search": {
      "KR": "구직",
      "VN": "Việc làm",
      "JP": "求職",
      "TH": "หางาน",
      "PH": "Jobs"
    },
    "talk": {
      "KR": "현지 톡톡",
      "VN": "Trò chuyện",
      "JP": "トーク",
      "TH": "คุย",
      "PH": "Talk"
    },
    "information": {
      "KR": "실시간 정보",
      "VN": "Tin tức",
      "JP": "情報",
      "TH": "ข้อมูล",
      "PH": "Info"
    },
    // Service Preparing
    "service_preparing": {
      "KR": "서비스 준비중입니다",
      "VN": "Dịch vụ đang được chuẩn bị",
      "JP": "サービス準備中です",
      "TH": "กำลังเตรียมบริการ",
      "PH": "Service is being prepared"
    }
  };
}
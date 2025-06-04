// lib/translations/main_translations.dart

class MainTranslations {
  static String getTranslation(String key, String language) {
    return translations[key]?[language] ?? translations[key]?['KR'] ?? key;
  }

  static const Map<String, Map<String, String>> translations = {
    // AnnouncementSection
    "review_reward_notice": {
      "KR": "리뷰 작성 시 리워드 지급 정책 안내",
      "JP": "レビュー作成時のリワード支給政策案内",
      "VN": "Hướng dẫn chính sách thưởng khi viết đánh giá",
      "TH": "แนะนำนโยบายการให้รางวัลเมื่อเขียนรีวิว",
      "TW": "撰寫評論時獎勵支付政策指南",
      "CN": "撰写评论时奖励支付政策指南",
      "HK": "撰寫評論時獎勵支付政策指南",
      "PH": "Review reward policy guide",
      "GU": "Review reward policy guide",
      "SG": "Review reward policy guide"
    },

    // MenuCards
    "my_info": {
      "KR": "내 정보",
      "JP": "マイ情報",
      "VN": "Thông tin của tôi",
      "TH": "ข้อมูลของฉัน",
      "TW": "我的資訊",
      "CN": "我的信息",
      "HK": "我的資訊",
      "PH": "My Info",
      "GU": "My Info",
      "SG": "My Info"
    },
    "chat": {
      "KR": "채팅",
      "JP": "チャット",
      "VN": "Trò chuyện",
      "TH": "แชท",
      "TW": "聊天",
      "CN": "聊天",
      "HK": "聊天",
      "PH": "Chat",
      "GU": "Chat",
      "SG": "Chat"
    },

    // TripFriendsBanner
    "learn_about": {
      "KR": "알아보기",
      "JP": "詳しく見る",
      "VN": "Tìm hiểu về",
      "TH": "เรียนรู้เกี่ยวกับ",
      "TW": "了解更多",
      "CN": "了解更多",
      "HK": "了解更多",
      "PH": "Learn about",
      "GU": "Learn about",
      "SG": "Learn about"
    },

    // ReservationCards
    "reservation": {
      "KR": "예약",
      "JP": "予約",
      "VN": "Đặt chỗ",
      "TH": "การจอง",
      "TW": "預約",
      "CN": "预约",
      "HK": "預約",
      "PH": "Reservation",
      "GU": "Reservation",
      "SG": "Reservation"
    },
    "past_reservation": {
      "KR": "지난예약",
      "JP": "過去の予約",
      "VN": "Đặt chỗ đã qua",
      "TH": "การจองที่ผ่านมา",
      "TW": "過去預約",
      "CN": "过去预约",
      "HK": "過去預約",
      "PH": "Past Reservations",
      "GU": "Past Reservations",
      "SG": "Past Reservations"
    },
    "count_unit": {
      "KR": "건",
      "JP": "件",
      "VN": "lượt",
      "TH": "รายการ",
      "TW": "筆",
      "CN": "笔",
      "HK": "筆",
      "PH": "items",
      "GU": "items",
      "SG": "items"
    },

    // Footer
    "ceo": {
      "KR": "대표",
      "JP": "代表",
      "VN": "Giám đốc",
      "TH": "ประธานกรรมการบริหาร",
      "TW": "執行長",
      "CN": "首席执行官",
      "HK": "執行長",
      "PH": "CEO",
      "GU": "CEO",
      "SG": "CEO"
    },
    "cto": {
      "KR": "기술이사",
      "JP": "技術責任者",
      "VN": "Giám đốc kỹ thuật",
      "TH": "ประธานเจ้าหน้าที่ฝ่ายเทคโนโลยี",
      "TW": "技術長",
      "CN": "首席技术官",
      "HK": "技術長",
      "PH": "CTO",
      "GU": "CTO",
      "SG": "CTO"
    },
    "cdd": {
      "KR": "디자인이사",
      "JP": "デザイン責任者",
      "VN": "Giám đốc thiết kế",
      "TH": "ประธานเจ้าหน้าที่ฝ่ายออกแบบ",
      "TW": "設計長",
      "CN": "首席设计官",
      "HK": "設計長",
      "PH": "CDD",
      "GU": "CDD",
      "SG": "CDD"
    },
    "business_registration_number": {
      "KR": "사업자등록번호",
      "JP": "事業者登録番号",
      "VN": "Số đăng ký kinh doanh",
      "TH": "เลขทะเบียนธุรกิจ",
      "TW": "營業登記號碼",
      "CN": "营业登记号码",
      "HK": "營業登記號碼",
      "PH": "Business Registration Number",
      "GU": "Business Registration Number",
      "SG": "Business Registration Number"
    },
    "ecommerce_registration_number": {
      "KR": "통신판매업신고번호",
      "JP": "通信販売業届出番号",
      "VN": "Số đăng ký bán hàng trực tuyến",
      "TH": "เลขทะเบียนการขายออนไลน์",
      "TW": "電子商務註冊號碼",
      "CN": "电子商务注册号码",
      "HK": "電子商務註冊號碼",
      "PH": "E-commerce Registration Number",
      "GU": "E-commerce Registration Number",
      "SG": "E-commerce Registration Number"
    },
    "tourism_business_license": {
      "KR": "관광사업등록번호",
      "JP": "観光事業登録番号",
      "VN": "Giấy phép kinh doanh du lịch",
      "TH": "ใบอนุญาตประกอบธุรกิจท่องเที่ยว",
      "TW": "旅遊業執照號碼",
      "CN": "旅游业执照号码",
      "HK": "旅遊業執照號碼",
      "PH": "Tourism Business License No.",
      "GU": "Tourism Business License No.",
      "SG": "Tourism Business License No."
    },
    "comprehensive_travel_business": {
      "KR": "종합여행업",
      "JP": "総合旅行業",
      "VN": "Kinh doanh du lịch tổng hợp",
      "TH": "ธุรกิจท่องเที่ยวแบบครบวงจร",
      "TW": "綜合旅行業",
      "CN": "综合旅行业",
      "HK": "綜合旅行業",
      "PH": "Comprehensive Travel Business",
      "GU": "Comprehensive Travel Business",
      "SG": "Comprehensive Travel Business"
    },
    "tel": {
      "KR": "전화",
      "JP": "電話",
      "VN": "Điện thoại",
      "TH": "โทรศัพท์",
      "TW": "電話",
      "CN": "电话",
      "HK": "電話",
      "PH": "Tel",
      "GU": "Tel",
      "SG": "Tel"
    },
    "seoul_gwangjin": {
      "KR": "서울광진",
      "JP": "ソウル広津",
      "VN": "Seoul Gwangjin",
      "TH": "โซลควังจิน",
      "TW": "首爾廣津",
      "CN": "首尔广津",
      "HK": "首爾廣津",
      "PH": "Seoul Gwangjin",
      "GU": "Seoul Gwangjin",
      "SG": "Seoul Gwangjin"
    },
    "achasan_address": {
      "KR": "서울특별시 광진구 아차산로62길 14-12 (구의동, 대영트윈)",
      "JP": "ソウル特別市広津区アチャ山路62キル14-12（九宜洞、大栄ツイン）",
      "VN": "14-12, Achasan-ro 62-gil, Gwangjin-gu, Seoul (Daeyeong Twin, Guui-dong)",
      "TH": "14-12 อาชาซัน-โร 62-กิล ควังจิน-กู โซล (แดยอง ทวิน, กูอี-ดง)",
      "TW": "首爾特別市廣津區阿且山路62街14-12（九宜洞，大榮雙子）",
      "CN": "首尔特别市广津区阿且山路62街14-12（九宜洞，大荣双子）",
      "HK": "首爾特別市廣津區阿且山路62街14-12（九宜洞，大榮雙子）",
      "PH": "14-12, Achasan-ro 62-gil, Gwangjin-gu, Seoul (Daeyeong Twin, Guui-dong)",
      "GU": "14-12, Achasan-ro 62-gil, Gwangjin-gu, Seoul (Daeyeong Twin, Guui-dong)",
      "SG": "14-12, Achasan-ro 62-gil, Gwangjin-gu, Seoul (Daeyeong Twin, Guui-dong)"
    },
    "republic_of_korea": {
      "KR": "대한민국",
      "JP": "大韓民国",
      "VN": "Hàn Quốc",
      "TH": "สาธารณรัฐเกาหลี",
      "TW": "大韓民國",
      "CN": "大韩民国",
      "HK": "大韓民國",
      "PH": "Republic of Korea",
      "GU": "Republic of Korea",
      "SG": "Republic of Korea"
    },

    // ReservationInfoCard - Status
    "status_pending": {
      "KR": "예약대기",
      "JP": "予約待機",
      "VN": "Đang chờ",
      "TH": "รอการจอง",
      "TW": "預約等待",
      "CN": "预约等待",
      "HK": "預約等待",
      "PH": "Pending",
      "GU": "Pending",
      "SG": "Pending"
    },
    "status_in_progress": {
      "KR": "진행중",
      "JP": "進行中",
      "VN": "Đang tiến hành",
      "TH": "กำลังดำเนินการ",
      "TW": "進行中",
      "CN": "进行中",
      "HK": "進行中",
      "PH": "In Progress",
      "GU": "In Progress",
      "SG": "In Progress"
    },
    "status_completed": {
      "KR": "예약완료",
      "JP": "予約完了",
      "VN": "Hoàn thành",
      "TH": "จองเสร็จสิ้น",
      "TW": "預約完成",
      "CN": "预约完成",
      "HK": "預約完成",
      "PH": "Completed",
      "GU": "Completed",
      "SG": "Completed"
    },
    "no_reservations_in_progress": {
      "KR": "진행 중인 예약이 없습니다",
      "JP": "進行中の予約がありません",
      "VN": "Không có đặt chỗ đang tiến hành",
      "TH": "ไม่มีการจองที่กำลังดำเนินการ",
      "TW": "沒有進行中的預約",
      "CN": "没有进行中的预约",
      "HK": "沒有進行中的預約",
      "PH": "No reservations in progress",
      "GU": "No reservations in progress",
      "SG": "No reservations in progress"
    },
    "total_completed_reservations": {
      "KR": "전체 완료 예약",
      "JP": "全体完了予約",
      "VN": "Đã sử dụng đầy đủ",
      "TH": "การจองที่เสร็จสิ้นทั้งหมด",
      "TW": "全部完成預約",
      "CN": "全部完成预约",
      "HK": "全部完成預約",
      "PH": "Total Completed Reservations",
      "GU": "Total Completed Reservations",
      "SG": "Total Completed Reservations"
    }
  };
}
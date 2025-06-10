// lib/translations/trip_main_translations.dart

class MainTranslations {
  static String getTranslation(String key, String language) {
    return translations[key]?[language] ?? translations[key]?['KR'] ?? key;
  }

  static const Map<String, Map<String, String>> translations = {
    // AnnouncementSection
    "review_reward_notice": {
      "KR": "리뷰 작성 시 리워드 지급 정책 안내",
      "VN": "Hướng dẫn chính sách thưởng khi viết đánh giá",
      "JP": "レビュー作成時のリワード支給政策案内",
      "TH": "แนะนำนโยบายการให้รางวัลเมื่อเขียนรีวิว",
      "PH": "Review reward policy guide"
    },

    // MenuCards
    "my_info": {
      "KR": "내 정보",
      "VN": "Thông tin của tôi",
      "JP": "マイ情報",
      "TH": "ข้อมูลของฉัน",
      "PH": "My Info"
    },
    "chat_list": {
      "KR": "채팅 리스트",
      "VN": "Danh sách trò chuyện",
      "JP": "チャットリスト",
      "TH": "รายการแชท",
      "PH": "Chat List"
    },
    "purchase_ticket": {
      "KR": "이용권 구매",
      "VN": "Mua vé sử dụng",
      "JP": "利用券購入",
      "TH": "ซื้อบัตรใช้งาน",
      "PH": "Purchase Ticket"
    },

    // TripFriendsBanner
    "how_to_use": {
      "KR": "이용방법",
      "VN": "Cách sử dụng",
      "JP": "利用方法",
      "TH": "วิธีใช้งาน",
      "PH": "How to use"
    },
    // ReservationCards
    "reservation": {
      "KR": "예약",
      "VN": "Đặt chỗ",
      "JP": "予約",
      "TH": "การจอง",
      "PH": "Reservation"
    },
    "past_reservation": {
      "KR": "지난예약",
      "VN": "Đặt chỗ đã qua",
      "JP": "過去の予約",
      "TH": "การจองที่ผ่านมา",
      "PH": "Past Reservations"
    },
    "count_unit": {
      "KR": "건",
      "VN": "lượt",
      "JP": "件",
      "TH": "รายการ",
      "PH": "items"
    },

    // Footer
    "ceo": {
      "KR": "대표",
      "VN": "Giám đốc",
      "JP": "代表",
      "TH": "ประธานกรรมการบริหาร",
      "PH": "CEO"
    },
    "cto": {
      "KR": "기술이사",
      "VN": "Giám đốc kỹ thuật",
      "JP": "技術責任者",
      "TH": "ประธานเจ้าหน้าที่ฝ่ายเทคโนโลยี",
      "PH": "CTO"
    },
    "cdd": {
      "KR": "디자인이사",
      "VN": "Giám đốc thiết kế",
      "JP": "デザイン責任者",
      "TH": "ประธานเจ้าหน้าที่ฝ่ายออกแบบ",
      "PH": "CDD"
    },
    "business_registration_number": {
      "KR": "사업자등록번호",
      "VN": "Số đăng ký kinh doanh",
      "JP": "事業者登録番号",
      "TH": "เลขทะเบียนธุรกิจ",
      "PH": "Business Registration Number"
    },
    "ecommerce_registration_number": {
      "KR": "통신판매업신고번호",
      "VN": "Số đăng ký bán hàng trực tuyến",
      "JP": "通信販売業届出番号",
      "TH": "เลขทะเบียนการขายออนไลน์",
      "PH": "E-commerce Registration Number"
    },
    "tourism_business_license": {
      "KR": "관광사업등록번호",
      "VN": "Giấy phép kinh doanh du lịch",
      "JP": "観光事業登録番号",
      "TH": "ใบอนุญาตประกอบธุรกิจท่องเที่ยว",
      "PH": "Tourism Business License No."
    },
    "comprehensive_travel_business": {
      "KR": "종합여행업",
      "VN": "Kinh doanh du lịch tổng hợp",
      "JP": "総合旅行業",
      "TH": "ธุรกิจท่องเที่ยวแบบครบวงจร",
      "PH": "Comprehensive Travel Business"
    },
    "tel": {
      "KR": "전화",
      "VN": "Điện thoại",
      "JP": "電話",
      "TH": "โทรศัพท์",
      "PH": "Tel"
    },
    "seoul_gwangjin": {
      "KR": "서울광진",
      "VN": "Seoul Gwangjin",
      "JP": "ソウル広津",
      "TH": "โซลควังจิน",
      "PH": "Seoul Gwangjin"
    },
    "achasan_address": {
      "KR": "서울특별시 광진구 아차산로62길 14-12 (구의동, 대영트윈)",
      "VN": "14-12, Achasan-ro 62-gil, Gwangjin-gu, Seoul (Daeyeong Twin, Guui-dong)",
      "JP": "ソウル特別市広津区アチャ山路62キル14-12（九宜洞、大栄ツイン）",
      "TH": "14-12 อาชาซัน-โร 62-กิล ควังจิน-กู โซล (แดยอง ทวิน, กูอี-ดง)",
      "PH": "14-12, Achasan-ro 62-gil, Gwangjin-gu, Seoul (Daeyeong Twin, Guui-dong)"
    },
    "republic_of_korea": {
      "KR": "대한민국",
      "VN": "Hàn Quốc",
      "JP": "大韓民国",
      "TH": "สาธารณรัฐเกาหลี",
      "PH": "Republic of Korea"
    },

    // ReservationInfoCard - Status
    "status_pending": {
      "KR": "예약대기",
      "VN": "Đang chờ",
      "JP": "予約待機",
      "TH": "รอการจอง",
      "PH": "Pending"
    },
    "status_in_progress": {
      "KR": "진행중",
      "VN": "Đang tiến hành",
      "JP": "進行中",
      "TH": "กำลังดำเนินการ",
      "PH": "In Progress"
    },
    "status_completed": {
      "KR": "예약완료",
      "VN": "Hoàn thành",
      "JP": "予約完了",
      "TH": "จองเสร็จสิ้น",
      "PH": "Completed"
    },
    "no_reservations_in_progress": {
      "KR": "진행 중인 예약이 없습니다",
      "VN": "Không có đặt chỗ đang tiến hành",
      "JP": "進行中の予約がありません",
      "TH": "ไม่มีการจองที่กำลังดำเนินการ",
      "PH": "No reservations in progress"
    },
    "total_completed_reservations": {
      "KR": "전체 완료 예약",
      "VN": "Đã sử dụng đầy đủ",
      "JP": "全体完了予約",
      "TH": "การจองที่เสร็จสิ้นทั้งหมด",
      "PH": "Total Completed Reservations"
    },
    // PointSection 관련
    "my_points": {
      "KR": "내 적립금",
      "VN": "Điểm của tôi",
      "JP": "マイポイント",
      "TH": "คะแนนสะสมของฉัน",
      "PH": "My Points"
    },
    "points_history": {
      "KR": "적립금 내역",
      "VN": "Lịch sử điểm",
      "JP": "ポイント履歴",
      "TH": "ประวัติคะแนน",
      "PH": "Points History"
    },
    "request_settlement": {
      "KR": "정산요청",
      "VN": "Yêu cầu thanh toán",
      "JP": "精算リクエスト",
      "TH": "ขอชำระเงิน",
      "PH": "Request Settlement"
    },
    "rank_up": {
      "KR": "RANK UP!",
      "VN": "NÂNG CẤP!",
      "JP": "ランクアップ！",
      "TH": "อัพเลเวล!",
      "PH": "RANK UP!"
    },
    "p_usage": {
      "KR": "사용",
      "VN": "sử dụng",
      "JP": "使用",
      "TH": "ใช้",
      "PH": "use"
    },
    "login_required": {
      "KR": "로그인이 필요합니다.",
      "VN": "Cần đăng nhập.",
      "JP": "ログインが必要です。",
      "TH": "ต้องเข้าสู่ระบบ",
      "PH": "Login required."
    },
    "user_not_found": {
      "KR": "사용자 정보를 찾을 수 없습니다.",
      "VN": "Không tìm thấy thông tin người dùng.",
      "JP": "ユーザー情報が見つかりません。",
      "TH": "ไม่พบข้อมูลผู้ใช้",
      "PH": "User information not found."
    },
    "no_user_data": {
      "KR": "사용자 데이터가 없습니다.",
      "VN": "Không có dữ liệu người dùng.",
      "JP": "ユーザーデータがありません。",
      "TH": "ไม่มีข้อมูลผู้ใช้",
      "PH": "No user data."
    },
    "insufficient_points": {
      "KR": "포인트가 부족합니다.",
      "VN": "Không đủ điểm.",
      "JP": "ポイントが不足しています。",
      "TH": "คะแนนไม่เพียงพอ",
      "PH": "Insufficient points."
    },
    "recommendation_activated": {
      "KR": "추천 프렌즈가 활성화되었습니다!",
      "VN": "Đã kích hoạt bạn bè giới thiệu!",
      "JP": "推薦フレンズが有効になりました！",
      "TH": "เปิดใช้งานเพื่อนแนะนำแล้ว!",
      "PH": "Recommended friends activated!"
    },
    "error_occurred": {
      "KR": "오류가 발생했습니다",
      "VN": "Đã xảy ra lỗi",
      "JP": "エラーが発生しました",
      "TH": "เกิดข้อผิดพลาด",
      "PH": "An error occurred"
    },
    "minimum_withdrawal": {
      "KR": "출금은 ₩ 100,000 이상부터 가능합니다.",
      "VN": "Rút tiền từ ₫ 2,000,000 trở lên.",
      "JP": "出金は¥ 100,000以上から可能です。",
      "TH": "ถอนเงินได้ตั้งแต่ ฿ 100,000 ขึ้นไป",
      "PH": "Withdrawal from ₱ 100,000 and above."
    },
  };
}
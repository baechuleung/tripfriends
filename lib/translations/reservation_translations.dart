// lib/translations/reservation_translations.dart

class ReservationTranslations {
  static String getTranslation(String key, String language) {
    return translations[key]?[language] ?? translations[key]?['KR'] ?? key;
  }

  static const Map<String, Map<String, String>> translations = {
    // Header
    "past_reservations": {
      "KR": "지난 예약 내역",
      "VN": "Lịch sử đặt chỗ",
      "JP": "過去の予約履歴",
      "TH": "ประวัติการจองที่ผ่านมา",
      "PH": "Past Reservations"
    },
    "current_reservations": {
      "KR": "예약목록",
      "VN": "Danh sách đặt chỗ",
      "JP": "予約リスト",
      "TH": "รายการจอง",
      "PH": "Reservation List"
    },

    // Status
    "service_completed_short": {
      "KR": "서비스 완료",
      "VN": "Dịch vụ hoàn thành",
      "JP": "サービス完了",
      "TH": "บริการเสร็จสิ้น",
      "PH": "Service Completed"
    },
    "reservation_pending": {
      "KR": "예약완료",
      "VN": "Đặt chỗ thành công",
      "JP": "予約完了",
      "TH": "จองสำเร็จ",
      "PH": "Reservation Complete"
    },
    "reservation_in_progress": {
      "KR": "진행중",
      "VN": "Đang tiến hành",
      "JP": "進行中",
      "TH": "กำลังดำเนินการ",
      "PH": "In Progress"
    },

    // Price
    "final_price": {
      "KR": "최종 요금",
      "VN": "Giá cuối cùng",
      "JP": "最終料金",
      "TH": "ราคาสุดท้าย",
      "PH": "Final Price"
    },
    "real_time_price": {
      "KR": "실시간 요금",
      "VN": "Giá thời gian thực",
      "JP": "リアルタイム料金",
      "TH": "ราคาแบบเรียลไทม์",
      "PH": "Real-time Price"
    },

    // Details
    "reservation_details": {
      "KR": "예약 상세 정보",
      "VN": "Chi tiết đặt chỗ",
      "JP": "予約詳細情報",
      "TH": "รายละเอียดการจอง",
      "PH": "Reservation Details"
    },
    "reservation_number": {
      "KR": "예약번호",
      "VN": "Mã đặt chỗ",
      "JP": "予約番号",
      "TH": "หมายเลขการจอง",
      "PH": "Reservation Number"
    },

    // Time
    "time_remaining": {
      "KR": "남음",
      "VN": "còn lại",
      "JP": "残り",
      "TH": "เหลือ",
      "PH": "remaining"
    },
    "time_passed": {
      "KR": "경과",
      "VN": "đã qua",
      "JP": "経過",
      "TH": "ผ่านไป",
      "PH": "passed"
    },
    "minutes": {
      "KR": "분",
      "VN": "phút",
      "JP": "分",
      "TH": "นาที",
      "PH": "minutes"
    },
    "hours": {
      "KR": "시간",
      "VN": "giờ",
      "JP": "時間",
      "TH": "ชั่วโมง",
      "PH": "hours"
    },
    "days": {
      "KR": "일",
      "VN": "ngày",
      "JP": "日",
      "TH": "วัน",
      "PH": "days"
    },

    // Date format
    "year_unit": {
      "KR": "년",
      "VN": "năm",
      "JP": "年",
      "TH": "ปี",
      "PH": "year"
    },
    "month_unit": {
      "KR": "월",
      "VN": "tháng",
      "JP": "月",
      "TH": "เดือน",
      "PH": "month"
    },
    "day_unit": {
      "KR": "일",
      "VN": "ngày",
      "JP": "日",
      "TH": "วัน",
      "PH": "day"
    },

    // Purpose
    "restaurant_cafe_tour": {
      "KR": "맛집/카페 탐방",
      "VN": "Khám phá nhà hàng/quán cà phê",
      "JP": "グルメ・カフェ巡り",
      "TH": "สำรวจร้านอาหาร/คาเฟ่",
      "PH": "Restaurant/Cafe Tour"
    },
    "market_shopping_tour": {
      "KR": "전통시장/쇼핑탐방",
      "VN": "Tham quan chợ truyền thống/mua sắm",
      "JP": "伝統市場・ショッピング巡り",
      "TH": "ท่องเที่ยวตลาดดั้งเดิม/ช้อปปิ้ง",
      "PH": "Traditional Market/Shopping Tour"
    },
    "culture_tour": {
      "KR": "문화/관광지 체험",
      "VN": "Trải nghiệm văn hóa/du lịch",
      "JP": "文化・観光地体験",
      "TH": "ประสบการณ์วัฒนธรรม/สถานที่ท่องเที่ยว",
      "PH": "Culture/Tourist Experience"
    },
    "night_companion": {
      "KR": "밤거리 동행",
      "VN": "Đồng hành ban đêm",
      "JP": "夜の街同行",
      "TH": "เพื่อนร่วมทางยามค่ำคืน",
      "PH": "Night Companion"
    },
    "free_schedule_companion": {
      "KR": "자유일정 동행/통역",
      "VN": "Đồng hành lịch trình tự do/phiên dịch",
      "JP": "自由日程同行・通訳",
      "TH": "เพื่อนร่วมทางตามกำหนดการอิสระ/ล่าม",
      "PH": "Free Schedule Companion/Interpreter"
    },
    "emergency_support": {
      "KR": "긴급 생활지원",
      "VN": "Hỗ trợ khẩn cấp",
      "JP": "緊急生活支援",
      "TH": "ช่วยเหลือฉุกเฉิน",
      "PH": "Emergency Support"
    },
    "other": {
      "KR": "기타",
      "VN": "Khác",
      "JP": "その他",
      "TH": "อื่นๆ",
      "PH": "Others"
    },
    "no_purpose_specified": {
      "KR": "목적 미지정",
      "VN": "Chưa chỉ định mục đích",
      "JP": "目的未指定",
      "TH": "ไม่ระบุวัตถุประสงค์",
      "PH": "No Purpose Specified"
    },

    // People count
    "people_count": {
      "KR": "명",
      "VN": "người",
      "JP": "名",
      "TH": "คน",
      "PH": "people"
    },

    // Actions
    "start_chat": {
      "KR": "채팅하기",
      "VN": "Bắt đầu trò chuyện",
      "JP": "チャットを開始",
      "TH": "เริ่มแชท",
      "PH": "Start Chat"
    },

    // Messages
    "loading_error": {
      "KR": "데이터를 불러오는 중 오류가 발생했습니다.",
      "VN": "Đã xảy ra lỗi khi tải dữ liệu.",
      "JP": "データの読み込み中にエラーが発生しました。",
      "TH": "เกิดข้อผิดพลาดในการโหลดข้อมูล",
      "PH": "Error loading data."
    },
    "no_past_reservations": {
      "KR": "지난 예약 내역이 없습니다.",
      "VN": "Không có lịch sử đặt chỗ.",
      "JP": "過去の予約履歴がありません。",
      "TH": "ไม่มีประวัติการจองที่ผ่านมา",
      "PH": "No past reservations."
    },
    "no_reservations": {
      "KR": "예약 내역이 없습니다.",
      "VN": "Không có lịch sử đặt chỗ.",
      "JP": "予約履歴がありません。",
      "TH": "ไม่มีประวัติการจอง",
      "PH": "No reservations."
    },
    "login_required": {
      "KR": "로그인이 필요합니다",
      "VN": "Cần đăng nhập",
      "JP": "ログインが必要です",
      "TH": "ต้องเข้าสู่ระบบ",
      "PH": "Login required"
    },
    "map_error": {
      "KR": "지도를 열 수 없습니다. 인터넷 연결을 확인해주세요.",
      "VN": "Không thể mở bản đồ. Vui lòng kiểm tra kết nối internet.",
      "JP": "地図を開けません。インターネット接続を確認してください。",
      "TH": "ไม่สามารถเปิดแผนที่ได้ กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต",
      "PH": "Cannot open map. Please check internet connection."
    },
    "location_map": {
      "KR": "위치 지도",
      "VN": "Bản đồ vị trí",
      "JP": "位置地図",
      "TH": "แผนที่ตำแหน่ง",
      "PH": "Location Map"
    }
  };
}
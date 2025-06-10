// lib/translations/mypage_translations.dart

class MypageTranslations {
  static String getTranslation(String key, String language) {
    return translations[key]?[language] ?? translations[key]?['KR'] ?? key;
  }

  static const Map<String, Map<String, String>> translations = {
    // Page Title
    "my_page": {
      "KR": "마이페이지",
      "VN": "Trang cá nhân",
      "JP": "マイページ",
      "TH": "หน้าของฉัน",
      "PH": "My Page"
    },

    // Profile Section
    "approval_complete": {
      "KR": "승인 완료",
      "VN": "Phê duyệt hoàn tất",
      "JP": "承認完了",
      "TH": "อนุมัติเรียบร้อย",
      "PH": "Approval Complete"
    },
    "approval_waiting": {
      "KR": "승인 대기중",
      "VN": "Đang chờ phê duyệt",
      "JP": "承認待ち",
      "TH": "รออนุมัติ",
      "PH": "Waiting for Approval"
    },
    "my_profile": {
      "KR": "나의 프로필",
      "VN": "Hồ sơ của tôi",
      "JP": "マイプロフィール",
      "TH": "โปรไฟล์ของฉัน",
      "PH": "My Profile"
    },
    "edit": {
      "KR": "수정하기",
      "VN": "Chỉnh sửa",
      "JP": "編集する",
      "TH": "แก้ไข",
      "PH": "Edit"
    },
    "profile_edit": {
      "KR": "프로필 수정",
      "VN": "Chỉnh sửa hồ sơ",
      "JP": "プロフィール編集",
      "TH": "แก้ไขโปรไฟล์",
      "PH": "Edit Profile"
    },
    "myinfo_edit": {
      "KR": "내정보 수정",
      "VN": "Chỉnh sửa thông tin của tôi",
      "JP": "個人情報編集",
      "TH": "แก้ไขข้อมูลของฉัน",
      "PH": "Edit My Info"
    },

    // Active Status
    "friend_status": {
      "KR": "프렌즈 활동 상태",
      "VN": "Trạng thái",
      "JP": "ステータス",
      "TH": "สถานะ",
      "PH": "Status"
    },
    "status_active": {
      "KR": "활성화 상태에서는 예약을 받을 수 있습니다.",
      "VN": "Có thể nhận đặt chỗ",
      "JP": "予約受付中",
      "TH": "รับการจองได้",
      "PH": "Can receive bookings"
    },
    "status_inactive": {
      "KR": "OFF 상태에서는 예약을 받을 수 없습니다.",
      "VN": "Không thể đặt chỗ",
      "JP": "予約停止中",
      "TH": "ไม่รับการจอง",
      "PH": "Cannot receive bookings"
    },

    // Info Section
    "available_languages": {
      "KR": "사용 가능 언어",
      "VN": "Ngôn ngữ có thể sử dụng",
      "JP": "使用可能言語",
      "TH": "ภาษาที่ใช้ได้",
      "PH": "Available Languages"
    },
    "introduction": {
      "KR": "소개",
      "VN": "Giới thiệu",
      "JP": "紹介",
      "TH": "แนะนำ",
      "PH": "Introduction"
    },
    "profile_reward_notice": {
      "KR": "소개글 300자 이상 작성 시 ₫36,000 지급!",
      "VN": "Viết giới thiệu trên 300 ký tự, nhận ₫36,000!",
      "JP": "紹介文を300文字以上書くと₫36,000支給！",
      "TH": "เขียนโปรไฟล์แนะนำเกิน 300 ตัวอักษร รับ ₫36,000!",
      "PH": "Write 300+ characters in your intro, get ₫36,000!"
    },
    "price_table": {
      "KR": "나의 활동비",
      "VN": "Chi phí hoạt động của tôi",
      "JP": "マイアクティビティ費用",
      "TH": "ค่ากิจกรรมของฉัน",
      "PH": "My Activity Fee"
    },
    "one_hour": {
      "KR": "기본 1 시간",
      "VN": "Cơ bản 1 giờ",
      "JP": "基本 1時間",
      "TH": "พื้นฐาน 1 ชั่วโมง",
      "PH": "Basic 1 hour"
    },
    "per_10_min": {
      "KR": "10 분당",
      "VN": "10 phút",
      "JP": "10分あたり",
      "TH": "ต่อ 10 นาที",
      "PH": "Per 10 min"
    },

    // Language Names
    "korean": {
      "KR": "한국어",
      "VN": "Tiếng Hàn",
      "JP": "韓国語",
      "TH": "ภาษาเกาหลี",
      "PH": "Korean"
    },
    "english": {
      "KR": "영어",
      "VN": "Tiếng Anh",
      "JP": "英語",
      "TH": "ภาษาอังกฤษ",
      "PH": "English"
    },
    "vietnamese": {
      "KR": "베트남어",
      "VN": "Tiếng Việt",
      "JP": "ベトナム語",
      "TH": "ภาษาเวียดนาม",
      "PH": "Vietnamese"
    },
    "japanese": {
      "KR": "일본어",
      "VN": "Tiếng Nhật",
      "JP": "日本語",
      "TH": "ภาษาญี่ปุ่น",
      "PH": "Japanese"
    },
    "thai": {
      "KR": "태국어",
      "VN": "Tiếng Thái",
      "JP": "タイ語",
      "TH": "ภาษาไทย",
      "PH": "Thai"
    },
    "filipino": {
      "KR": "필리핀어",
      "VN": "Tiếng Philippines",
      "JP": "フィリピン語",
      "TH": "ภาษาฟิลิปปินส์",
      "PH": "Filipino"
    },

    // Recommended Friends
    "recommended_friends": {
      "KR": "추천 프렌즈",
      "VN": "Bạn bè được đề xuất",
      "JP": "おすすめのフレンズ",
      "TH": "เพื่อนที่แนะนำ",
      "PH": "Recommended Friends"
    },
    "recommended_friends_desc": {
      "KR": "나를 추천한 친구들의 목록을 확인하세요!",
      "VN": "Xem danh sách bạn bè đã giới thiệu bạn!",
      "JP": "あなたを推薦した友達の一覧を確認しましょう！",
      "TH": "ดูรายชื่อเพื่อนที่แนะนำคุณ!",
      "PH": "See the list of friends who recommended you!"
    },
    "recommended_friends_list": {
      "KR": "추천한프렌즈",
      "VN": "Danh sách bạn bè đã giới thiệu",
      "JP": "推薦した友達",
      "TH": "เพื่อนที่คุณแนะนำ",
      "PH": "Recommended Friends"
    },
    "no_recommended_friends": {
      "KR": "나를 추천한 친구가 없습니다",
      "VN": "Không có ai giới thiệu bạn",
      "JP": "あなたを推薦した友達はいません",
      "TH": "ไม่มีเพื่อนที่แนะนำคุณ",
      "PH": "No one has recommended you."
    },
    "partner_code": {
      "KR": "파트너 코드",
      "VN": "Mã đối tác",
      "JP": "パートナーコード",
      "TH": "รหัสพาร์ทเนอร์",
      "PH": "Partner Code"
    },
    "copy": {
      "KR": "복사",
      "VN": "Sao chép",
      "JP": "コピー",
      "TH": "คัดลอก",
      "PH": "Copy"
    },
    "code_copied": {
      "KR": "코드가 복사되었습니다",
      "VN": "Mã đã được sao chép",
      "JP": "コードがコピーされました",
      "TH": "คัดลอกรหัสแล้ว",
      "PH": "Code has been copied"
    },

    // Points & Balance
    "my_point": {
      "KR": "MY POINT",
      "VN": "ĐIỂM CỦA TÔI",
      "JP": "マイポイント",
      "TH": "คะแนนของฉัน",
      "PH": "MY POINT"
    },
    "rank_up": {
      "KR": "LANK UP!",
      "VN": "NÂNG CẤP!",
      "JP": "ランクアップ！",
      "TH": "อัพเลเวล!",
      "PH": "RANK UP!"
    },
    "point_usage_question": {
      "KR": "포인트를\n사용하시겠습니까?",
      "VN": "Bạn có muốn\nsử dụng điểm không?",
      "JP": "ポイントを\n使用しますか?",
      "TH": "คุณต้องการ\nใช้แต้มหรือไม่?",
      "PH": "Gusto mo bang\ngamitin ang puntos?"
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
      "JP": "확認",
      "TH": "ยืนยัน",
      "PH": "Confirm"
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

    // Balance & Withdrawal
    "balance_history": {
      "KR": "적립내역",
      "VN": "Lịch sử",
      "JP": "履歴",
      "TH": "ประวัติ",
      "PH": "History"
    },
    "withdraw": {
      "KR": "출금하기",
      "VN": "Rút tiền",
      "JP": "出金する",
      "TH": "ถอนเงิน",
      "PH": "Withdraw"
    },
    "minimum_withdrawal": {
      "KR": "출금은 {symbol} {amount} 이상 부터 가능합니다.",
      "VN": "Rút tiền từ {symbol} {amount} trở lên.",
      "JP": "出金は{symbol} {amount}以上から可能です。",
      "TH": "ถอนเงินได้ตั้งแต่ {symbol} {amount} ขึ้นไป",
      "PH": "Withdrawal from {symbol} {amount} and above."
    },

    // Balance History Filters
    "filter_type": {
      "KR": "유형",
      "VN": "Loại",
      "JP": "タイプ",
      "TH": "ประเภท",
      "PH": "Type"
    },
    "filter_all": {
      "KR": "전체",
      "VN": "Tất cả",
      "JP": "全体",
      "TH": "ทั้งหมด",
      "PH": "All"
    },
    "filter_earn": {
      "KR": "적립",
      "VN": "Tích lũy",
      "JP": "積立",
      "TH": "สะสม",
      "PH": "Earn"
    },
    "filter_withdrawal": {
      "KR": "출금",
      "VN": "Rút tiền",
      "JP": "出金",
      "TH": "ถอนเงิน",
      "PH": "Withdrawal"
    },
    "filter_period": {
      "KR": "기간",
      "VN": "Thời gian",
      "JP": "期間",
      "TH": "ระยะเวลา",
      "PH": "Period"
    },
    "filter_period_all": {
      "KR": "전체",
      "VN": "Tất cả",
      "JP": "全体",
      "TH": "ทั้งหมด",
      "PH": "All"
    },
    "filter_period_week": {
      "KR": "일주일",
      "VN": "Một tuần",
      "JP": "一週間",
      "TH": "หนึ่งสัปดาห์",
      "PH": "One week"
    },
    "filter_period_month": {
      "KR": "1개월",
      "VN": "1 tháng",
      "JP": "1ヶ月",
      "TH": "1 เดือน",
      "PH": "1 month"
    },
    "filter_period_3months": {
      "KR": "3개월",
      "VN": "3 tháng",
      "JP": "3ヶ月",
      "TH": "3 เดือน",
      "PH": "3 months"
    },

    // Balance History Status
    "type_earn": {
      "KR": "적립",
      "VN": "Tích lũy",
      "JP": "積立",
      "TH": "สะสม",
      "PH": "Earn"
    },
    "type_withdrawal": {
      "KR": "출금",
      "VN": "Rút tiền",
      "JP": "出金",
      "TH": "ถอนเงิน",
      "PH": "Withdrawal"
    },
    "type_unknown": {
      "KR": "기타",
      "VN": "Khác",
      "JP": "その他",
      "TH": "อื่นๆ",
      "PH": "Others"
    },
    "status_pending": {
      "KR": "처리 중",
      "VN": "Đang xử lý",
      "JP": "処理中",
      "TH": "กำลังดำเนินการ",
      "PH": "Processing"
    },
    "status_completed": {
      "KR": "완료",
      "VN": "Hoàn thành",
      "JP": "完了",
      "TH": "เสร็จสิ้น",
      "PH": "Completed"
    },
    "status_rejected": {
      "KR": "거절됨",
      "VN": "Bị từ chối",
      "JP": "拒否された",
      "TH": "ถูกปฏิเสธ",
      "PH": "Rejected"
    },
    "status_unknown": {
      "KR": "알 수 없음",
      "VN": "Không xác định",
      "JP": "不明",
      "TH": "ไม่ทราบ",
      "PH": "Unknown"
    },

    // Balance History Sources
    "source_video_upload": {
      "KR": "동영상 업로드",
      "VN": "Tải lên video",
      "JP": "動画アップロード",
      "TH": "อัปโหลดวิดีโอ",
      "PH": "Video Upload"
    },
    "source_profile_completion": {
      "KR": "프로필 완성",
      "VN": "Hoàn thành hồ sơ",
      "JP": "プロフィール完成",
      "TH": "เสร็จสิ้นโปรไฟล์",
      "PH": "Profile Completion"
    },
    "source_withdrawal": {
      "KR": "적립금 출금",
      "VN": "Rút tiền tích lũy",
      "JP": "積立金出金",
      "TH": "ถอนเงินสะสม",
      "PH": "Balance Withdrawal"
    },
    "source_referral": {
      "KR": "친구 초대",
      "VN": "Mời bạn bè",
      "JP": "友達招待",
      "TH": "เชิญเพื่อน",
      "PH": "Friend Referral"
    },
    "source_review": {
      "KR": "리뷰 작성",
      "VN": "Viết đánh giá",
      "JP": "レビュー作成",
      "TH": "เขียนรีวิว",
      "PH": "Write Review"
    },
    "source_unknown": {
      "KR": "적립금 적립",
      "VN": "Tích lũy điểm",
      "JP": "積立金積立",
      "TH": "สะสมเงิน",
      "PH": "Balance Earn"
    },

    // Withdrawal Page
    "bank_info": {
      "KR": "출금 계좌 정보",
      "VN": "Thông tin tài khoản rút tiền",
      "JP": "出金口座情報",
      "TH": "ข้อมูลบัญชีถอนเงิน",
      "PH": "Withdrawal Account Info"
    },
    "bank_name": {
      "KR": "은행명",
      "VN": "Tên ngân hàng",
      "JP": "銀行名",
      "TH": "ชื่อธนาคาร",
      "PH": "Bank Name"
    },
    "enter_bank_name": {
      "KR": "은행명을 입력해주세요",
      "VN": "Vui lòng nhập tên ngân hàng",
      "JP": "銀行名を入力してください",
      "TH": "กรุณาใส่ชื่อธนาคาร",
      "PH": "Please enter bank name"
    },
    "account_number": {
      "KR": "계좌번호",
      "VN": "Số tài khoản",
      "JP": "口座番号",
      "TH": "เลขที่บัญชี",
      "PH": "Account Number"
    },
    "enter_account_number": {
      "KR": "계좌번호를 입력해주세요",
      "VN": "Vui lòng nhập số tài khoản",
      "JP": "口座番号を入力してください",
      "TH": "กรุณาใส่เลขที่บัญชี",
      "PH": "Please enter account number"
    },
    "account_holder": {
      "KR": "예금주",
      "VN": "Chủ tài khoản",
      "JP": "預金主",
      "TH": "ชื่อบัญชี",
      "PH": "Account Holder"
    },
    "enter_account_holder": {
      "KR": "예금주를 입력해주세요",
      "VN": "Vui lòng nhập tên chủ tài khoản",
      "JP": "預金主を入力してください",
      "TH": "กรุณาใส่ชื่อบัญชี",
      "PH": "Please enter account holder"
    },
    "receiver_address": {
      "KR": "수취인 주소",
      "VN": "Địa chỉ người nhận",
      "JP": "受取人住所",
      "TH": "ที่อยู่ผู้รับ",
      "PH": "Receiver Address"
    },
    "enter_receiver_address": {
      "KR": "수취인 주소를 입력해주세요",
      "VN": "Vui lòng nhập địa chỉ người nhận",
      "JP": "受取人住所を入力してください",
      "TH": "กรุณาใส่ที่อยู่ผู้รับ",
      "PH": "Please enter receiver address"
    },
    "swift_code": {
      "KR": "SWIFT 코드",
      "VN": "Mã SWIFT",
      "JP": "SWIFTコード",
      "TH": "รหัส SWIFT",
      "PH": "SWIFT Code"
    },
    "enter_swift_code": {
      "KR": "SWIFT 코드를 입력해주세요",
      "VN": "Vui lòng nhập mã SWIFT",
      "JP": "SWIFTコードを入力してください",
      "TH": "กรุณาใส่รหัส SWIFT",
      "PH": "Please enter SWIFT code"
    },
    "edit_bank_info": {
      "KR": "계좌 정보 수정",
      "VN": "Sửa thông tin tài khoản",
      "JP": "口座情報修正",
      "TH": "แก้ไขข้อมูลบัญชี",
      "PH": "Edit Account Info"
    },
    "withdrawal_amount": {
      "KR": "출금액",
      "VN": "Số tiền rút",
      "JP": "出金額",
      "TH": "จำนวนเงินถอน",
      "PH": "Withdrawal Amount"
    },
    "minimum_withdrawal_info": {
      "KR": "* 최소 출금 금액은 100,000원 이상이어야 합니다.",
      "VN": "* Số tiền rút tối thiểu phải từ 2,000,000 đồng trở lên.",
      "JP": "* 最小出金額は100,000円以上でなければなりません。",
      "TH": "* จำนวนเงินถอนขั้นต่ำต้องมากกว่า 100,000 บาท",
      "PH": "* Minimum withdrawal amount must be 100,000 pesos or more."
    },

    // Withdrawal Dialog
    "withdrawal_request": {
      "KR": "출금 신청",
      "VN": "Yêu cầu rút tiền",
      "JP": "出金申請",
      "TH": "ขอถอนเงิน",
      "PH": "Withdrawal Request"
    },
    "withdrawal_success": {
      "KR": "출금 요청은 관리자가 수동으로 처리하며, 2~3일 소요됩니다.",
      "VN": "Yêu cầu rút tiền được xử lý thủ công bởi quản trị viên và mất 2-3 ngày.",
      "JP": "出金リクエストは管理者が手動で処理し、2〜3日かかります。",
      "TH": "คำขอถอนเงินจะดำเนินการโดยผู้ดูแลระบบและใช้เวลา 2-3 วัน",
      "PH": "Withdrawal requests are processed manually by admin and take 2-3 days."
    },
    "confirm_withdrawal": {
      "KR": "출금 확인",
      "VN": "Xác nhận rút tiền",
      "JP": "出金確認",
      "TH": "ยืนยันการถอนเงิน",
      "PH": "Confirm Withdrawal"
    },
    "confirm_withdrawal_message": {
      "KR": "정말로 출금 신청을 하시겠습니까?",
      "VN": "Bạn có chắc chắn muốn yêu cầu rút tiền không?",
      "JP": "本当に出金申請をしますか？",
      "TH": "คุณแน่ใจหรือไม่ว่าต้องการขอถอนเงิน?",
      "PH": "Are you sure you want to request withdrawal?"
    },
    "processing": {
      "KR": "처리 중...",
      "VN": "Đang xử lý...",
      "JP": "処理中...",
      "TH": "กำลังดำเนินการ...",
      "PH": "Processing..."
    },

    // Error Messages
    "error": {
      "KR": "오류",
      "VN": "Lỗi",
      "JP": "エラー",
      "TH": "ข้อผิดพลาด",
      "PH": "Error"
    },
    "error_login_required": {
      "KR": "로그인이 필요합니다",
      "VN": "Cần đăng nhập",
      "JP": "ログインが必要です",
      "TH": "ต้องเข้าสู่ระบบ",
      "PH": "Login required"
    },
    "error_loading_history": {
      "KR": "적립금 내역을 불러오는 중 오류가 발생했습니다",
      "VN": "Đã xảy ra lỗi khi tải lịch sử tích điểm",
      "JP": "積立金履歴の読み込み中にエラーが発生しました",
      "TH": "เกิดข้อผิดพลาดในการโหลดประวัติเงินสะสม",
      "PH": "Error loading balance history"
    },
    "no_balance_history": {
      "KR": "적립금 내역이 없습니다",
      "VN": "Không có lịch sử tích điểm",
      "JP": "積立金履歴がありません",
      "TH": "ไม่มีประวัติเงินสะสม",
      "PH": "No balance history"
    },
    "no_filtered_history": {
      "KR": "해당 내역이 없습니다",
      "VN": "Không có lịch sử tương ứng",
      "JP": "該当する履歴がありません",
      "TH": "ไม่มีประวัติที่ตรงกัน",
      "PH": "No matching history"
    },
    "try_again": {
      "KR": "다시 시도",
      "VN": "Thử lại",
      "JP": "再試行",
      "TH": "ลองอีกครั้ง",
      "PH": "Try Again"
    },
    "total_transactions": {
      "KR": "총 거래 건수",
      "VN": "Tổng số giao dịch",
      "JP": "総取引件数",
      "TH": "จำนวนธุรกรรมทั้งหมด",
      "PH": "Total Transactions"
    },
    "count_unit": {
      "KR": "건",
      "VN": "lượt",
      "JP": "件",
      "TH": "รายการ",
      "PH": "items"
    },

    // Withdrawal Errors
    "below_minimum": {
      "KR": "최소 출금 금액은 100,000원 이상입니다.",
      "VN": "Số tiền rút tối thiểu là 2,000,000 đồng trở lên.",
      "JP": "最小出金額は100,000円以上です。",
      "TH": "จำนวนเงินถอนขั้นต่ำคือ 100,000 บาทขึ้นไป",
      "PH": "Minimum withdrawal amount is 100,000 pesos or more."
    },
    "no_bank_info": {
      "KR": "출금 정보를 먼저 입력해주세요.",
      "VN": "Vui lòng nhập thông tin rút tiền trước.",
      "JP": "出金情報を先に入力してください。",
      "TH": "กรุณากรอกข้อมูลการถอนเงินก่อน",
      "PH": "Please enter withdrawal information first."
    },
    "bank_info_required": {
      "KR": "출금 정보를 모두 입력해주세요.",
      "VN": "Vui lòng nhập đầy đủ thông tin rút tiền.",
      "JP": "出金情報をすべて入力してください。",
      "TH": "กรุณากรอกข้อมูลการถอนเงินให้ครบถ้วน",
      "PH": "Please enter all withdrawal information."
    },
    "withdrawal_error": {
      "KR": "출금 신청 중 오류가 발생했습니다.",
      "VN": "Đã xảy ra lỗi khi yêu cầu rút tiền.",
      "JP": "出金申請中にエラーが発生しました。",
      "TH": "เกิดข้อผิดพลาดในการขอถอนเงิน",
      "PH": "Error occurred during withdrawal request."
    },
    "withdrawal_description": {
      "KR": "적립금 출금",
      "VN": "Rút tiền tích lũy",
      "JP": "積立金出金",
      "TH": "ถอนเงินสะสม",
      "PH": "Balance Withdrawal"
    },

    // Balance History Item
    "earn_points": {
      "KR": "적립금 적립",
      "VN": "Tích lũy điểm",
      "JP": "積立金積立",
      "TH": "สะสมเงิน",
      "PH": "Earn Points"
    },
    "use_points": {
      "KR": "적립금 사용",
      "VN": "Sử dụng điểm",
      "JP": "積立金使用",
      "TH": "ใช้เงินสะสม",
      "PH": "Use Points"
    },
    "withdraw_points": {
      "KR": "적립금 출금",
      "VN": "Rút tiền tích lũy",
      "JP": "積立金出金",
      "TH": "ถอนเงินสะสม",
      "PH": "Withdraw Points"
    },
    "points_transaction": {
      "KR": "적립금 거래",
      "VN": "Giao dịch điểm",
      "JP": "積立金取引",
      "TH": "ธุรกรรมเงินสะสม",
      "PH": "Points Transaction"
    },

    // Logout
    "logout": {
      "KR": "로그아웃",
      "VN": "Đăng xuất",
      "JP": "ログアウト",
      "TH": "ออกจากระบบ",
      "PH": "Logout"
    },
    "logout_confirmation": {
      "KR": "정말 로그아웃 하시겠습니까?",
      "VN": "Bạn có chắc chắn muốn đăng xuất không?",
      "JP": "本当にログアウトしますか？",
      "TH": "คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?",
      "PH": "Are you sure you want to logout?"
    },
    "logout_success": {
      "KR": "로그아웃되었습니다",
      "VN": "Đã đăng xuất",
      "JP": "ログアウトしました",
      "TH": "ออกจากระบบแล้ว",
      "PH": "Logged out successfully"
    },
    "logout_failed": {
      "KR": "로그아웃 실패",
      "VN": "Đăng xuất thất bại",
      "JP": "ログアウト失敗",
      "TH": "ออกจากระบบล้มเหลว",
      "PH": "Logout failed"
    }
  };
}
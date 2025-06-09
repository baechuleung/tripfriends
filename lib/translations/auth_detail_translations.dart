// lib/translations/auth_detail_translations.dart

class AuthDetailTranslations {
  static String getTranslation(String key, String language) {
    return translations[key]?[language] ?? translations[key]?['KR'] ?? key;
  }

  static const Map<String, Map<String, String>> translations = {
    "introduction": {
      "KR": "자기소개",
      "VN": "Giới thiệu bản thân",
      "JP": "自己紹介",
      "TH": "แนะนำตัว",
      "PH": "Self Introduction"
    },
    "introduction_placeholder": {
      "KR": "당신의 특별한 경험과 장점을 알려주세요.\n여행자들에게 어떤 도움을 줄 수 있는지 설명해주세요.",
      "VN": "Hãy cho biết kinh nghiệm và điểm mạnh đặc biệt của bạn.\nGiải thích bạn có thể giúp du khách như thế nào.",
      "JP": "あなたの特別な経験と長所を教えてください。\n旅行者にどのような助けができるか説明してください。",
      "TH": "บอกเล่าประสบการณ์และจุดเด่นพิเศษของคุณ\nอธิบายว่าคุณสามารถช่วยเหลือนักท่องเที่ยวได้อย่างไร",
      "PH": "Tell us about your special experiences and strengths.\nExplain how you can help travelers."
    },
    // 자기소개 작성 안내
    "introduction_writing_guide": {
      "KR": "자기소개 작성 안내",
      "VN": "Hướng dẫn viết giới thiệu bản thân",
      "JP": "自己紹介作成案内",
      "TH": "คำแนะนำการเขียนแนะนำตัว",
      "PH": "Self-introduction Writing Guide"
    },
    "introduction_writing_guide_title": {
      "KR": "자기소개 작성 안내",
      "VN": "Hướng dẫn viết giới thiệu bản thân",
      "JP": "自己紹介作成案内",
      "TH": "คำแนะนำการเขียนแนะนำตัว",
      "PH": "Self-introduction Writing Guide"
    },
    "introduction_reward_desc": {
      "KR": "소개글 300자 이상 작성 시 ₩ 36,000이 지급됩니다.",
      "VN": "Viết giới thiệu từ 300 ký tự trở lên sẽ được trả ₫ 36,000.",
      "JP": "紹介文300文字以上作成時¥36,000が支給されます。",
      "TH": "เขียนข้อความแนะนำตัว 300 ตัวอักษรขึ้นไปจะได้รับ ฿36,000",
      "PH": "Writing an introduction of 300+ characters will receive ₱36,000."
    },
    "introduction_content_guide": {
      "KR": "자신을 소개하는 내용을 작성해 주세요.",
      "VN": "Vui lòng viết nội dung giới thiệu về bản thân.",
      "JP": "自分を紹介する内容を作成してください。",
      "TH": "โปรดเขียนเนื้อหาแนะนำตัวเอง",
      "PH": "Please write content introducing yourself."
    },
    "introduction_warning_desc": {
      "KR": "형식적인 글이나 의미 없는 문장, 문자 수만 채우기 위한 반복된 내용을 입력할 경우, 활동이 제한될 수 있습니다.",
      "VN": "Nếu nhập nội dung mang tính hình thức, câu không có ý nghĩa, hoặc nội dung lặp lại chỉ để tăng số ký tự, hoạt động có thể bị hạn chế.",
      "JP": "形式的な文章や意味のない文、文字数を埋めるためだけの繰り返し内容を入力した場合、活動が制限される場合があります。",
      "TH": "หากป้อนข้อความที่เป็นทางการ ประโยคที่ไม่มีความหมาย หรือเนื้อหาซ้ำซากเพียงเพื่อเพิ่มจำนวนตัวอักษร กิจกรรมอาจถูกจำกัด",
      "PH": "If you enter formal text, meaningless sentences, or repetitive content just to fill character count, activities may be restricted."
    },
    "introduction_ad_warning": {
      "KR": "자기소개가 아닌 광고 또는 무성의한 문장은 인정되지 않습니다.",
      "VN": "Quảng cáo hoặc câu văn không chân thành thay vì giới thiệu bản thân sẽ không được chấp nhận.",
      "JP": "自己紹介ではない広告や不誠実な文章は認められません。",
      "TH": "โฆษณาหรือประโยคที่ไม่จริงใจแทนการแนะนำตัวจะไม่ได้รับการยอมรับ",
      "PH": "Advertisements or insincere sentences instead of self-introduction will not be accepted."
    },
    "reward_payment_guide": {
      "KR": "적립금 지급 안내",
      "VN": "Hướng dẫn thanh toán điểm thưởng",
      "JP": "積立金支給案内",
      "TH": "คำแนะนำการจ่ายเงินรางวัล",
      "PH": "Reward Payment Guide"
    },
    "reward_review_notice": {
      "KR": "신뢰할 수 있는 플랫폼 운영을 위해 관리자의 검토 후, 조건을 충족하지 않은 경우 적립금은 지급 되지 않습니다.",
      "VN": "Để vận hành nền tảng đáng tin cậy, sau khi quản trị viên xem xét, nếu không đáp ứng điều kiện thì điểm thưởng sẽ không được trả.",
      "JP": "信頼できるプラットフォーム運営のため、管理者の検討後、条件を満たさない場合は積立金は支給されません。",
      "TH": "เพื่อการดำเนินงานแพลตฟอร์มที่เชื่อถือได้ หลังจากการตรวจสอบของผู้ดูแลระบบ หากไม่เป็นไปตามเงื่อนไข เงินรางวัลจะไม่ถูกจ่าย",
      "PH": "For reliable platform operation, after administrator review, if conditions are not met, rewards will not be paid."
    },
    "introduction_min_length": {
      "KR": "최소 100자 이상 작성해주세요.",
      "VN": "Vui lòng viết ít nhất 100 ký tự.",
      "JP": "最低100文字以上作成してください。",
      "TH": "โปรดเขียนอย่างน้อย 100 ตัวอักษร",
      "PH": "Please write at least 100 characters."
    }
  };
}
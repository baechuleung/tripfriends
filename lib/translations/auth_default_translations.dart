// lib/translations/auth_default_translations.dart

class AuthDefaultTranslations {
  static String getTranslation(String key, String language) {
    return translations[key]?[language] ?? translations[key]?['KR'] ?? key;
  }

  static const Map<String, Map<String, String>> translations = {
    // 이미지 및 영상 업로드 안내
    "upload_guide_title": {
      "KR": "이미지 및 영상 업로드 제출 안내",
      "JP": "画像と動画のアップロード提出案内",
      "VN": "Hướng dẫn tải lên hình ảnh và video",
      "TH": "คำแนะนำการอัปโหลดรูปภาพและวิดีโอ",
      "TW": "圖片及影片上傳提交指南",
      "CN": "图片及视频上传提交指南",
      "HK": "圖片及影片上傳提交指南",
      "PH": "Image and Video Upload Guide",
      "GU": "Image and Video Upload Guide",
      "SG": "Image and Video Upload Guide"
    },

    // 프로필 이미지
    "profile_image_guide_title": {
      "KR": "프로필 이미지",
      "JP": "プロフィール画像",
      "VN": "Ảnh hồ sơ",
      "TH": "รูปโปรไฟล์",
      "TW": "個人照片",
      "CN": "个人照片",
      "HK": "個人照片",
      "PH": "Profile Image",
      "GU": "Profile Image",
      "SG": "Profile Image"
    },
    "profile_image_guide_desc1": {
      "KR": "본인의 얼굴이 정면으로 보이는 사진이어야 합니다.",
      "JP": "本人の顔が正面から見える写真である必要があります。",
      "VN": "Phải là ảnh nhìn thấy khuôn mặt của bạn từ phía trước.",
      "TH": "ต้องเป็นรูปถ่ายที่เห็นใบหน้าของคุณจากด้านหน้า",
      "TW": "必須是能從正面看到您臉部的照片。",
      "CN": "必须是能从正面看到您脸部的照片。",
      "HK": "必須是能從正面看到您臉部的照片。",
      "PH": "Must be a photo showing your face from the front.",
      "GU": "Must be a photo showing your face from the front.",
      "SG": "Must be a photo showing your face from the front."
    },
    "profile_image_guide_desc2": {
      "KR": "마스크, 선글라스, 풍경 또는 타인의 사진은 인정되지 않습니다.",
      "JP": "マスク、サングラス、風景または他人の写真は認められません。",
      "VN": "Không chấp nhận ảnh đeo khẩu trang, kính râm, phong cảnh hoặc ảnh của người khác.",
      "TH": "ไม่ยอมรับรูปที่สวมหน้ากาก แว่นกันแดด ภูมิทัศน์ หรือรูปของผู้อื่น",
      "TW": "不接受戴口罩、太陽眼鏡、風景或他人的照片。",
      "CN": "不接受戴口罩、太阳眼镜、风景或他人的照片。",
      "HK": "不接受戴口罩、太陽眼鏡、風景或他人的照片。",
      "PH": "Photos with masks, sunglasses, scenery, or other people are not accepted.",
      "GU": "Photos with masks, sunglasses, scenery, or other people are not accepted.",
      "SG": "Photos with masks, sunglasses, scenery, or other people are not accepted."
    },

    // 자기소개 동영상
    "intro_video_guide_title": {
      "KR": "자기소개 동영상",
      "JP": "自己紹介動画",
      "VN": "Video giới thiệu bản thân",
      "TH": "วิดีโอแนะนำตัว",
      "TW": "自我介紹影片",
      "CN": "自我介绍视频",
      "HK": "自我介紹影片",
      "PH": "Self-introduction Video",
      "GU": "Self-introduction Video",
      "SG": "Self-introduction Video"
    },
    "intro_video_guide_desc1_prefix": {
      "KR": "영상 업로드 시 ",
      "JP": "動画アップロード時 ",
      "VN": "Tải lên video nhận ",
      "TH": "อัปโหลดวิดีโอรับ ",
      "TW": "上傳影片可獲得 ",
      "CN": "上传视频可获得 ",
      "HK": "上傳影片可獲得 ",
      "PH": "Upload video and get ",
      "GU": "Upload video and get ",
      "SG": "Upload video and get "
    },
    "intro_video_guide_desc1_amount": {
      "KR": "₩ 54,000",
      "JP": "¥ 54,000",
      "VN": "₫ 54,000",
      "TH": "฿ 54,000",
      "TW": "NT\$ 54,000",
      "CN": "¥ 54,000",
      "HK": "HK\$ 54,000",
      "PH": "₱ 54,000",
      "GU": "\$ 54,000",
      "SG": "S\$ 54,000"
    },
    "intro_video_guide_desc1_suffix": {
      "KR": " 지급!",
      "JP": " 支給！",
      "VN": "!",
      "TH": "!",
      "TW": "！",
      "CN": "！",
      "HK": "！",
      "PH": "!",
      "GU": "!",
      "SG": "!"
    },
    "intro_video_guide_desc2": {
      "KR": "본인이 직접 자신을 소개하는 영상이어야 합니다.",
      "JP": "本人が直接自己紹介する動画である必要があります。",
      "VN": "Phải là video bạn tự giới thiệu bản thân.",
      "TH": "ต้องเป็นวิดีโอที่คุณแนะนำตัวเองโดยตรง",
      "TW": "必須是您親自介紹自己的影片。",
      "CN": "必须是您亲自介绍自己的视频。",
      "HK": "必須是您親自介紹自己的影片。",
      "PH": "Must be a video of you introducing yourself directly.",
      "GU": "Must be a video of you introducing yourself directly.",
      "SG": "Must be a video of you introducing yourself directly."
    },
    "intro_video_guide_desc3": {
      "KR": "광고성 영상, 텍스트 영상 등 관련이 없는 영상은 보상이 지급되지 않습니다.",
      "JP": "広告動画、テキスト動画など関連のない動画には報酬が支給されません。",
      "VN": "Video quảng cáo, video văn bản và các video không liên quan sẽ không được thưởng.",
      "TH": "วิดีโอโฆษณา วิดีโอข้อความ และวิดีโอที่ไม่เกี่ยวข้องจะไม่ได้รับรางวัล",
      "TW": "廣告影片、文字影片等無關影片將不給予獎勵。",
      "CN": "广告视频、文字视频等无关视频将不给予奖励。",
      "HK": "廣告影片、文字影片等無關影片將不給予獎勵。",
      "PH": "Advertisement videos, text videos, and unrelated videos will not be rewarded.",
      "GU": "Advertisement videos, text videos, and unrelated videos will not be rewarded.",
      "SG": "Advertisement videos, text videos, and unrelated videos will not be rewarded."
    },

    // 적립금 지급 안내
    "reward_guide_title": {
      "KR": "적립금 지급 안내",
      "JP": "ポイント支給案内",
      "VN": "Hướng dẫn chi trả điểm thưởng",
      "TH": "คำแนะนำการจ่ายคะแนนสะสม",
      "TW": "積分支付指南",
      "CN": "积分支付指南",
      "HK": "積分支付指南",
      "PH": "Reward Points Payment Guide",
      "GU": "Reward Points Payment Guide",
      "SG": "Reward Points Payment Guide"
    },
    "reward_guide_desc": {
      "KR": "신뢰할 수 있는 플랫폼 운영을 위해 관리자의 검토 후, 조건을 충족하지 않은 경우 적립금은 지급 되지 않습니다.",
      "JP": "信頼できるプラットフォーム運営のため、管理者の検討後、条件を満たさない場合はポイントが支給されません。",
      "VN": "Để vận hành nền tảng đáng tin cậy, sau khi quản trị viên xem xét, nếu không đáp ứng điều kiện thì điểm thưởng sẽ không được chi trả.",
      "TH": "เพื่อการดำเนินแพลตฟอร์มที่น่าเชื่อถือ หลังจากผู้ดูแลระบบตรวจสอบแล้ว หากไม่ตรงตามเงื่อนไข คะแนนสะสมจะไม่ถูกจ่าย",
      "TW": "為了可信賴的平台運營，管理員審核後，如不符合條件，將不支付積分。",
      "CN": "为了可信赖的平台运营，管理员审核后，如不符合条件，将不支付积分。",
      "HK": "為了可信賴的平台運營，管理員審核後，如不符合條件，將不支付積分。",
      "PH": "For reliable platform operation, points will not be paid if conditions are not met after administrator review.",
      "GU": "For reliable platform operation, points will not be paid if conditions are not met after administrator review.",
      "SG": "For reliable platform operation, points will not be paid if conditions are not met after administrator review."
    },
  };
}
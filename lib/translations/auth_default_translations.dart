// lib/translations/auth_default_translations.dart

class AuthDefaultTranslations {
  static String getTranslation(String key, String language) {
    return translations[key]?[language] ?? translations[key]?['KR'] ?? key;
  }

  static const Map<String, Map<String, String>> translations = {
    // 프로필 미디어 등록
    "profileImage": {
      "KR": "프로필 미디어 등록하기",
      "JP": "プロフィールメディア登録",
      "VN": "Đăng ký phương tiện hồ sơ",
      "TH": "ลงทะเบียนสื่อโปรไฟล์",
      "PH": "Register Profile Media",
      "MY": "Daftar Media Profil",
      "EN": "Register Profile Media"
    },
    "profileDescription": {
      "KR": "자신을 소개할 짧은 영상과 사진을 올려주세요!",
      "JP": "自己紹介の短い動画と写真をアップロードしてください！",
      "VN": "Hãy tải lên video và ảnh ngắn giới thiệu về bản thân!",
      "TH": "กรุณาอัปโหลดวิดีโอและรูปภาพสั้นๆ แนะนำตัวคุณ!",
      "PH": "Please upload short videos and photos introducing yourself!",
      "MY": "Sila muat naik video dan gambar pendek memperkenalkan diri anda!",
      "EN": "Please upload short videos and photos introducing yourself!"
    },
    "uploadImage": {
      "KR": "이미지",
      "JP": "画像",
      "VN": "Hình ảnh",
      "TH": "รูปภาพ",
      "PH": "Image",
      "MY": "Imej",
      "EN": "Image"
    },
    "uploadVideo": {
      "KR": "동영상",
      "JP": "動画",
      "VN": "Video",
      "TH": "วิดีโอ",
      "PH": "Video",
      "MY": "Video",
      "EN": "Video"
    },
    "uploadedMedia": {
      "KR": "업로드된 미디어",
      "JP": "アップロードされたメディア",
      "VN": "Phương tiện đã tải lên",
      "TH": "สื่อที่อัปโหลด",
      "PH": "Uploaded Media",
      "MY": "Media Dimuat Naik",
      "EN": "Uploaded Media"
    },
    "mainPhoto": {
      "KR": "대표",
      "JP": "代表",
      "VN": "Đại diện",
      "TH": "หลัก",
      "PH": "Main",
      "MY": "Utama",
      "EN": "Main"
    },
    "imageErrorMsg": {
      "KR": "이미지 선택 중 오류가 발생했습니다.",
      "JP": "画像選択中にエラーが発生しました。",
      "VN": "Đã xảy ra lỗi khi chọn hình ảnh.",
      "TH": "เกิดข้อผิดพลาดขณะเลือกรูปภาพ",
      "PH": "An error occurred while selecting the image.",
      "MY": "Ralat berlaku semasa memilih imej.",
      "EN": "An error occurred while selecting the image."
    },
    "videoErrorMsg": {
      "KR": "동영상 선택 중 오류가 발생했습니다.",
      "JP": "動画選択中にエラーが発生しました。",
      "VN": "Đã xảy ra lỗi khi chọn video.",
      "TH": "เกิดข้อผิดพลาดขณะเลือกวิดีโอ",
      "PH": "An error occurred while selecting the video.",
      "MY": "Ralat berlaku semasa memilih video.",
      "EN": "An error occurred while selecting the video."
    },
    "firstItemImageError": {
      "KR": "첫 번째 항목은 이미지여야 합니다. 먼저 이미지를 선택해주세요.",
      "JP": "最初の項目は画像である必要があります。まず画像を選択してください。",
      "VN": "Mục đầu tiên phải là hình ảnh. Vui lòng chọn hình ảnh trước.",
      "TH": "รายการแรกต้องเป็นรูปภาพ กรุณาเลือกรูปภาพก่อน",
      "PH": "The first item must be an image. Please select an image first.",
      "MY": "Item pertama mestilah imej. Sila pilih imej terlebih dahulu.",
      "EN": "The first item must be an image. Please select an image first."
    },
    "deleteErrorMsg": {
      "KR": "미디어 삭제 중 오류가 발생했습니다.",
      "JP": "メディア削除中にエラーが発生しました。",
      "VN": "Đã xảy ra lỗi khi xóa phương tiện.",
      "TH": "เกิดข้อผิดพลาดขณะลบสื่อ",
      "PH": "An error occurred while deleting media.",
      "MY": "Ralat berlaku semasa memadam media.",
      "EN": "An error occurred while deleting media."
    },

    // 이미지 및 영상 업로드 안내
    "upload_guide_title": {
      "KR": "이미지 및 영상 업로드 제출 안내",
      "JP": "画像と動画のアップロード提出案内",
      "VN": "Hướng dẫn tải lên hình ảnh và video",
      "TH": "คำแนะนำการอัปโหลดรูปภาพและวิดีโอ",
      "PH": "Image and Video Upload Guide",
      "MY": "Panduan Muat Naik Imej dan Video",
      "EN": "Image and Video Upload Guide"
    },

    // 프로필 이미지
    "profile_image_guide_title": {
      "KR": "프로필 이미지",
      "JP": "プロフィール画像",
      "VN": "Ảnh hồ sơ",
      "TH": "รูปโปรไฟล์",
      "PH": "Profile Image",
      "MY": "Imej Profil",
      "EN": "Profile Image"
    },
    "profile_image_guide_desc1": {
      "KR": "본인의 얼굴이 정면으로 보이는 사진이어야 합니다.",
      "JP": "本人の顔が正面から見える写真である必要があります。",
      "VN": "Phải là ảnh nhìn thấy khuôn mặt của bạn từ phía trước.",
      "TH": "ต้องเป็นรูปถ่ายที่เห็นใบหน้าของคุณจากด้านหน้า",
      "PH": "Must be a photo showing your face from the front.",
      "MY": "Mestilah gambar yang menunjukkan wajah anda dari hadapan.",
      "EN": "Must be a photo showing your face from the front."
    },
    "profile_image_guide_desc2": {
      "KR": "마스크, 선글라스, 풍경 또는 타인의 사진은 인정되지 않습니다.",
      "JP": "マスク、サングラス、風景または他人の写真は認められません。",
      "VN": "Không chấp nhận ảnh đeo khẩu trang, kính râm, phong cảnh hoặc ảnh của người khác.",
      "TH": "ไม่ยอมรับรูปที่สวมหน้ากาก แว่นกันแดด ภูมิทัศน์ หรือรูปของผู้อื่น",
      "PH": "Photos with masks, sunglasses, scenery, or other people are not accepted.",
      "MY": "Gambar dengan topeng, cermin mata hitam, pemandangan atau orang lain tidak diterima.",
      "EN": "Photos with masks, sunglasses, scenery, or other people are not accepted."
    },

    // 자기소개 동영상
    "intro_video_guide_title": {
      "KR": "자기소개 동영상",
      "JP": "自己紹介動画",
      "VN": "Video giới thiệu bản thân",
      "TH": "วิดีโอแนะนำตัว",
      "PH": "Self-introduction Video",
      "MY": "Video Perkenalan Diri",
      "EN": "Self-introduction Video"
    },
    "intro_video_guide_desc2": {
      "KR": "본인이 직접 자신을 소개하는 영상이어야 합니다.",
      "JP": "本人が直接自己紹介する動画である必要があります。",
      "VN": "Phải là video bạn tự giới thiệu bản thân.",
      "TH": "ต้องเป็นวิดีโอที่คุณแนะนำตัวเองโดยตรง",
      "PH": "Must be a video of you introducing yourself directly.",
      "MY": "Mestilah video anda memperkenalkan diri secara langsung.",
      "EN": "Must be a video of you introducing yourself directly."
    },
    "intro_video_guide_desc3": {
      "KR": "광고성 영상, 텍스트 영상 등 관련이 없는 영상은 보상이 지급되지 않습니다.",
      "JP": "広告動画、テキスト動画など関連のない動画には報酬が支給されません。",
      "VN": "Video quảng cáo, video văn bản và các video không liên quan sẽ không được thưởng.",
      "TH": "วิดีโอโฆษณา วิดีโอข้อความ และวิดีโอที่ไม่เกี่ยวข้องจะไม่ได้รับรางวัล",
      "PH": "Advertisement videos, text videos, and unrelated videos will not be rewarded.",
      "MY": "Video iklan, video teks dan video tidak berkaitan tidak akan diberi ganjaran.",
      "EN": "Advertisement videos, text videos, and unrelated videos will not be rewarded."
    },

    // 적립금 지급 안내
    "reward_guide_title": {
      "KR": "적립금 지급 안내",
      "JP": "ポイント支給案内",
      "VN": "Hướng dẫn chi trả điểm thưởng",
      "TH": "คำแนะนำการจ่ายคะแนนสะสม",
      "PH": "Reward Points Payment Guide",
      "MY": "Panduan Pembayaran Mata Ganjaran",
      "EN": "Reward Points Payment Guide"
    },
    "reward_guide_desc": {
      "KR": "신뢰할 수 있는 플랫폼 운영을 위해 관리자의 검토 후, 조건을 충족하지 않은 경우 적립금은 지급 되지 않습니다.",
      "JP": "信頼できるプラットフォーム運営のため、管理者の検討後、条件を満たさない場合はポイントが支給されません。",
      "VN": "Để vận hành nền tảng đáng tin cậy, sau khi quản trị viên xem xét, nếu không đáp ứng điều kiện thì điểm thưởng sẽ không được chi trả.",
      "TH": "เพื่อการดำเนินแพลตฟอร์มที่น่าเชื่อถือ หลังจากผู้ดูแลระบบตรวจสอบแล้ว หากไม่ตรงตามเงื่อนไข คะแนนสะสมจะไม่ถูกจ่าย",
      "PH": "For reliable platform operation, points will not be paid if conditions are not met after administrator review.",
      "MY": "Untuk operasi platform yang boleh dipercayai, mata tidak akan dibayar jika syarat tidak dipenuhi selepas semakan pentadbir.",
      "EN": "For reliable platform operation, points will not be paid if conditions are not met after administrator review."
    },
  };
}
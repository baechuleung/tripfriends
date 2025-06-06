import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:convert';
import 'models/media_info.dart';

class ProfileController {
  final String uid;
  final FirebaseStorage _storage;
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final ValueNotifier<String?> profileImageNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<List<MediaInfo>> profileMediaNotifier = ValueNotifier<List<MediaInfo>>([]);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> referralCodeNotifier = ValueNotifier<String?>(null);

  // 상태 변경 콜백
  final VoidCallback? onChanged;

  // 번역 관련
  Map<String, String> currentLabels = {
    "profileImage": "프로필 미디어 등록하기",
    "profileDescription": "자신을 소개할 짧은 영상과 사진을 올려주세요!",
    "uploadImage": "이미지",
    "uploadVideo": "동영상",
    "uploadedMedia": "업로드된 미디어",
    "mainPhoto": "대표",
    "imageErrorMsg": "이미지 선택 중 오류가 발생했습니다.",
    "videoErrorMsg": "동영상 선택 중 오류가 발생했습니다.",
    "firstItemImageError": "첫 번째 항목은 이미지여야 합니다. 먼저 이미지를 선택해주세요.",
    "deleteErrorMsg": "미디어 삭제 중 오류가 발생했습니다.",
    "upload_guide_title": "이미지 및 영상 업로드 제출 안내",
    "profile_image_guide_title": "프로필 이미지",
    "profile_image_guide_desc1": "본인의 얼굴이 정면으로 보이는 사진이어야 합니다.",
    "profile_image_guide_desc2": "마스크, 선글라스, 풍경 또는 타인의 사진은 인정되지 않습니다.",
    "intro_video_guide_title": "자기소개 동영상",
    "intro_video_guide_desc1": "영상 업로드 시 본인이 직접 자신을 소개하는 영상이어야 합니다.",
    "intro_video_guide_desc2": "본인이 직접 자신을 소개하는 영상이어야 합니다.",
    "intro_video_guide_desc3": "광고성 영상, 텍스트 영상 등 관련이 없는 영상은 보상이 지급되지 않습니다.",
    "reward_guide_title": "적립금 지급 안내",
    "reward_guide_desc": "신뢰할 수 있는 플랫폼 운영을 위해 관리자의 검토 후, 조건을 충족하지 않은 경우 적립금은 지급 되지 않습니다."
  };

  ProfileController({
    required this.uid,
    FirebaseStorage? storage,
    this.onChanged,
  }) : _storage = storage ?? FirebaseStorage.instance;

  String? get profileImagePath => profileImageNotifier.value;
  List<MediaInfo> get profileMediaList => profileMediaNotifier.value;
  String? get referralCode => referralCodeNotifier.value;
  bool get isLoading => isLoadingNotifier.value;

  bool hasValidProfileMedia() {
    return profileMediaList.isNotEmpty &&
        profileMediaList[0].type == MediaType.image;
  }

  Future<MediaInfo?> pickImage() async {
    try {
      isLoadingNotifier.value = true;

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return MediaInfo(
          path: pickedFile.path,
          type: MediaType.image,
        );
      }
      return null;
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  Future<MediaInfo?> pickVideo() async {
    try {
      isLoadingNotifier.value = true;

      final XFile? pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 1),
      );

      if (pickedFile != null) {
        return MediaInfo(
          path: pickedFile.path,
          type: MediaType.video,
        );
      }
      return null;
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  void addMedia(MediaInfo mediaInfo) {
    final updatedList = List<MediaInfo>.from(profileMediaList);
    updatedList.add(mediaInfo);
    profileMediaNotifier.value = updatedList;

    if (updatedList.isNotEmpty && updatedList[0].type == MediaType.image) {
      profileImageNotifier.value = updatedList[0].path;
    }

    if (onChanged != null) {
      onChanged!();
    }
  }

  void removeMedia(int index) async {
    try {
      final updatedList = List<MediaInfo>.from(profileMediaList);
      if (index >= 0 && index < updatedList.length) {
        final mediaToRemove = updatedList[index];

        // 1. Storage에서 삭제 (URL인 경우만)
        if (mediaToRemove.path.startsWith('http')) {
          try {
            final ref = _storage.refFromURL(mediaToRemove.path);
            await ref.delete();
            print('Storage에서 미디어 삭제 완료');
          } catch (e) {
            print('Storage 삭제 실패: $e');
          }
        }

        // 2. UI 리스트에서 삭제
        updatedList.removeAt(index);
        profileMediaNotifier.value = updatedList;

        // 첫 번째 항목이 변경된 경우 프로필 이미지 업데이트
        if (updatedList.isNotEmpty && updatedList[0].type == MediaType.image) {
          profileImageNotifier.value = updatedList[0].path;
        } else if (updatedList.isEmpty) {
          profileImageNotifier.value = null;
        }

        // 3. Firestore에서도 업데이트
        try {
          // 남은 미디어 리스트를 Map 형태로 변환
          List<Map<String, dynamic>> mediaUrls = [];
          String? profileImageUrl;

          for (int i = 0; i < updatedList.length; i++) {
            final media = updatedList[i];
            mediaUrls.add(media.toMap());

            if (i == 0 && media.type == MediaType.image) {
              profileImageUrl = media.path;
            }
          }

          // Firestore 업데이트
          await _firestore.collection("tripfriends_users").doc(uid).update({
            'profileMediaList': mediaUrls,
            'profileImageUrl': profileImageUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          print('Firestore 업데이트 완료');
        } catch (e) {
          print('Firestore 업데이트 실패: $e');
        }

        if (onChanged != null) {
          onChanged!();
        }
      }
    } catch (e) {
      print('미디어 삭제 중 오류 발생: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadProfileMedia() async {
    List<Map<String, dynamic>> mediaUrls = [];
    String? profileImageUrl;

    for (int i = 0; i < profileMediaList.length; i++) {
      final mediaInfo = profileMediaList[i];

      if (mediaInfo.path.startsWith('http')) {
        mediaUrls.add(mediaInfo.toMap());
        if (i == 0 && mediaInfo.type == MediaType.image) {
          profileImageUrl = mediaInfo.path;
        }
        continue;
      }

      try {
        final File mediaFile = File(mediaInfo.path);

        if (!await mediaFile.exists()) {
          continue;
        }

        final fileExt = mediaInfo.type == MediaType.image ? 'jpg' : 'mp4';
        final storageRef = _storage
            .ref()
            .child('tripfriends_profiles')
            .child(uid)
            .child('media_${i}_${DateTime.now().millisecondsSinceEpoch}.$fileExt');

        final uploadTask = storageRef.putFile(mediaFile);
        await uploadTask.whenComplete(() => null);

        if (uploadTask.snapshot.state == TaskState.success) {
          final mediaUrl = await storageRef.getDownloadURL();

          mediaUrls.add({
            'path': mediaUrl,
            'type': mediaInfo.type == MediaType.image ? 'image' : 'video',
          });

          if (i == 0 && mediaInfo.type == MediaType.image) {
            profileImageUrl = mediaUrl;
          }
        }
      } catch (e) {
        // 개별 업로드 실패는 전체 프로세스를 중단하지 않음
      }
    }

    return {
      'profileImageUrl': profileImageUrl,
      'mediaUrls': mediaUrls,
    };
  }

  Future<String> generateUniqueReferralCode() async {
    // 8자리 숫자 추천 코드 생성
    String code = '${DateTime.now().millisecondsSinceEpoch % 100000000}'.padLeft(8, '0');
    bool exists = await _isReferralCodeExists(code);

    while (exists) {
      code = '${DateTime.now().microsecondsSinceEpoch % 100000000}'.padLeft(8, '0');
      exists = await _isReferralCodeExists(code);
    }

    referralCodeNotifier.value = code;
    return code;
  }

  Future<bool> _isReferralCodeExists(String code) async {
    final snapshot = await _firestore
        .collection("tripfriends_users")
        .where("referrer_code", isEqualTo: code)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // 스크롤 컨트롤 메서드
  void scrollToEnd(ScrollController scrollController) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> loadTranslations(String currentCountryCode) async {
    try {
      final String translationJson = await rootBundle.loadString('assets/data/auth_translations.json');
      final Map<String, dynamic> translationData = json.decode(translationJson);

      final translations = translationData['translations'];

      if (translations['profile_image_register'] != null) {
        currentLabels['profileImage'] = translations['profile_image_register'][currentCountryCode];
      }
      if (translations['profile_description'] != null) {
        currentLabels['profileDescription'] = translations['profile_description'][currentCountryCode];
      }
      if (translations['upload_image'] != null) {
        currentLabels['uploadImage'] = translations['upload_image'][currentCountryCode];
      }
      if (translations['upload_video'] != null) {
        currentLabels['uploadVideo'] = translations['upload_video'][currentCountryCode];
      }
      if (translations['uploaded_media'] != null) {
        currentLabels['uploadedMedia'] = translations['uploaded_media'][currentCountryCode];
      }
      if (translations['main_photo'] != null) {
        currentLabels['mainPhoto'] = translations['main_photo'][currentCountryCode];
      }
      if (translations['image_error_msg'] != null) {
        currentLabels['imageErrorMsg'] = translations['image_error_msg'][currentCountryCode];
      }
      if (translations['video_error_msg'] != null) {
        currentLabels['videoErrorMsg'] = translations['video_error_msg'][currentCountryCode];
      }
      if (translations['first_item_image_error'] != null) {
        currentLabels['firstItemImageError'] = translations['first_item_image_error'][currentCountryCode];
      }
      if (translations['delete_error_msg'] != null) {
        currentLabels['deleteErrorMsg'] = translations['delete_error_msg'][currentCountryCode];
      }
      if (translations['upload_guide_title'] != null) {
        currentLabels['upload_guide_title'] = translations['upload_guide_title'][currentCountryCode];
      }
      if (translations['profile_image_guide_title'] != null) {
        currentLabels['profile_image_guide_title'] = translations['profile_image_guide_title'][currentCountryCode];
      }
      if (translations['profile_image_guide_desc1'] != null) {
        currentLabels['profile_image_guide_desc1'] = translations['profile_image_guide_desc1'][currentCountryCode];
      }
      if (translations['profile_image_guide_desc2'] != null) {
        currentLabels['profile_image_guide_desc2'] = translations['profile_image_guide_desc2'][currentCountryCode];
      }
      if (translations['intro_video_guide_title'] != null) {
        currentLabels['intro_video_guide_title'] = translations['intro_video_guide_title'][currentCountryCode];
      }
      if (translations['intro_video_guide_desc1'] != null) {
        currentLabels['intro_video_guide_desc1'] = translations['intro_video_guide_desc1'][currentCountryCode];
      }
      if (translations['intro_video_guide_desc2'] != null) {
        currentLabels['intro_video_guide_desc2'] = translations['intro_video_guide_desc2'][currentCountryCode];
      }
      if (translations['intro_video_guide_desc3'] != null) {
        currentLabels['intro_video_guide_desc3'] = translations['intro_video_guide_desc3'][currentCountryCode];
      }
      if (translations['reward_guide_title'] != null) {
        currentLabels['reward_guide_title'] = translations['reward_guide_title'][currentCountryCode];
      }
      if (translations['reward_guide_desc'] != null) {
        currentLabels['reward_guide_desc'] = translations['reward_guide_desc'][currentCountryCode];
      }
    } catch (e) {
      print('Error loading translations: $e');
    }
  }

  void dispose() {
    profileImageNotifier.dispose();
    profileMediaNotifier.dispose();
    isLoadingNotifier.dispose();
    referralCodeNotifier.dispose();
  }
}
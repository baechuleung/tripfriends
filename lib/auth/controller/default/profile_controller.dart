import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'models/media_info.dart';
import '../../../translations/auth_default_translations.dart';

class ProfileController {
  final String uid;
  final FirebaseStorage _storage;
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final ValueNotifier<String?> profileImageNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<List<MediaInfo>> profileMediaNotifier = ValueNotifier<List<MediaInfo>>([]);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> referralCodeNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<int> mainImageIndexNotifier = ValueNotifier<int>(0);

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
  int get mainImageIndex => mainImageIndexNotifier.value;

  bool hasValidProfileMedia() {
    // 미디어가 있고, 대표 이미지 인덱스의 항목이 이미지인지 확인
    if (profileMediaList.isEmpty) return false;

    // 이미지가 최소 1개는 있어야 함
    final hasImage = profileMediaList.any((media) => media.type == MediaType.image);
    return hasImage;
  }

  // 대표 이미지로 설정
  void setMainImage(int index) {
    if (index >= 0 && index < profileMediaList.length &&
        profileMediaList[index].type == MediaType.image) {

      // 이미 대표 이미지인 경우 아무 작업도 하지 않음
      if (index == 0) return;

      // 리스트를 복사하고 선택된 이미지를 맨 앞으로 이동
      final updatedList = List<MediaInfo>.from(profileMediaList);
      final selectedMedia = updatedList.removeAt(index);
      updatedList.insert(0, selectedMedia);

      // 리스트 업데이트
      profileMediaNotifier.value = updatedList;
      mainImageIndexNotifier.value = 0;  // 이제 대표 이미지는 항상 0번 인덱스
      profileImageNotifier.value = updatedList[0].path;

      if (onChanged != null) {
        onChanged!();
      }
    }
  }

  // 첫 번째 이미지의 인덱스 찾기
  int _findFirstImageIndex() {
    for (int i = 0; i < profileMediaList.length; i++) {
      if (profileMediaList[i].type == MediaType.image) {
        return i;
      }
    }
    return -1;
  }

  Future<MediaInfo?> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        print('원본 경로: ${pickedFile.path}');

        if (Platform.isIOS) {
          // 단순히 JPEG로 재저장
          final bytes = await pickedFile.readAsBytes();
          final tempDir = await getApplicationDocumentsDirectory();
          final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final newPath = path.join(tempDir.path, fileName);

          final newFile = File(newPath);
          await newFile.writeAsBytes(bytes);

          return MediaInfo(
            path: newPath,
            type: MediaType.image,
          );
        } else {
          return MediaInfo(
            path: pickedFile.path,
            type: MediaType.image,
          );
        }
      }
      return null;
    } catch (e) {
      print('이미지 선택 오류: $e');
      rethrow;
    }
  }

  Future<MediaInfo?> pickVideo() async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 1),
      );

      if (pickedFile != null) {
        if (Platform.isIOS) {
          // iOS에서 비디오도 동일하게 처리
          final bytes = await pickedFile.readAsBytes();
          final tempDir = await getApplicationDocumentsDirectory();
          final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
          final newPath = path.join(tempDir.path, fileName);

          final newFile = File(newPath);
          await newFile.writeAsBytes(bytes);

          return MediaInfo(
            path: newPath,
            type: MediaType.video,
          );
        } else {
          return MediaInfo(
            path: pickedFile.path,
            type: MediaType.video,
          );
        }
      }
      return null;
    } catch (e) {
      print('비디오 선택 오류: $e');
      rethrow;
    }
  }

  void addMedia(MediaInfo mediaInfo) {
    final updatedList = List<MediaInfo>.from(profileMediaList);

    // 이미지인 경우와 비디오인 경우를 구분
    if (mediaInfo.type == MediaType.image) {
      // 이미지가 하나도 없었던 경우 맨 앞에 추가
      if (!updatedList.any((m) => m.type == MediaType.image)) {
        updatedList.insert(0, mediaInfo);
        mainImageIndexNotifier.value = 0;
        profileImageNotifier.value = mediaInfo.path;
      } else {
        // 이미 이미지가 있는 경우 뒤에 추가
        updatedList.add(mediaInfo);
      }
    } else {
      // 비디오는 항상 뒤에 추가
      updatedList.add(mediaInfo);
    }

    profileMediaNotifier.value = updatedList;

    if (onChanged != null) {
      onChanged!();
    }
  }

  void removeMedia(int index) async {
    try {
      final updatedList = List<MediaInfo>.from(profileMediaList);
      if (index >= 0 && index < updatedList.length) {
        final mediaToRemove = updatedList[index];
        final wasMainImage = index == 0 && mediaToRemove.type == MediaType.image;

        // 1. Storage에서 삭제 (URL인 경우만)
        if (mediaToRemove.path.startsWith('http')) {
          try {
            final ref = _storage.refFromURL(mediaToRemove.path);
            await ref.delete();
            print('Storage에서 미디어 삭제 완료');
          } catch (e) {
            print('Storage 삭제 실패: $e');
          }
        } else {
          // 로컬 파일 삭제
          final file = File(mediaToRemove.path);
          if (await file.exists()) {
            await file.delete();
            print('로컬 파일 삭제 완료');
          }
        }

        // 2. UI 리스트에서 삭제
        updatedList.removeAt(index);
        profileMediaNotifier.value = updatedList;

        // 3. 대표 이미지가 삭제된 경우 다음 이미지를 대표로 설정
        if (wasMainImage && updatedList.isNotEmpty) {
          // 첫 번째 이미지를 찾아서 대표로 설정
          final firstImageIndex = _findFirstImageIndex();
          if (firstImageIndex != -1) {
            // 첫 번째 이미지를 맨 앞으로 이동
            final firstImage = updatedList.removeAt(firstImageIndex);
            updatedList.insert(0, firstImage);
            profileMediaNotifier.value = updatedList;
            mainImageIndexNotifier.value = 0;
            profileImageNotifier.value = updatedList[0].path;
          } else {
            profileImageNotifier.value = null;
          }
        } else if (updatedList.isEmpty) {
          mainImageIndexNotifier.value = 0;
          profileImageNotifier.value = null;
        }

        // 4. Firestore에서도 업데이트
        try {
          List<Map<String, dynamic>> mediaUrls = [];
          String? profileImageUrl;

          for (int i = 0; i < updatedList.length; i++) {
            final media = updatedList[i];
            mediaUrls.add(media.toMap());

            if (i == 0 && media.type == MediaType.image) {
              profileImageUrl = media.path;
            }
          }

          await _firestore.collection("tripfriends_users").doc(uid).update({
            'profileMediaList': mediaUrls,
            'profileImageUrl': profileImageUrl,
            'mainImageIndex': 0,  // 항상 0번이 대표
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
        // 첫 번째 항목이 이미지인 경우 대표 이미지로 설정
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

        // 원본 파일의 확장자를 유지
        String fileExt;
        if (mediaInfo.type == MediaType.image) {
          final extension = mediaInfo.path.split('.').last.toLowerCase();
          if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
            fileExt = extension;
          } else {
            fileExt = 'jpg';
          }
        } else {
          fileExt = 'mp4';
        }

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

          // 첫 번째 항목이 이미지인 경우 대표 이미지로 설정
          if (i == 0 && mediaInfo.type == MediaType.image) {
            profileImageUrl = mediaUrl;
          }
        }
      } catch (e) {
        print('업로드 오류: $e');
      }
    }

    return {
      'profileImageUrl': profileImageUrl,
      'mediaUrls': mediaUrls,
      'mainImageIndex': 0,  // 항상 0번이 대표
    };
  }

  Future<String> generateUniqueReferralCode() async {
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
      print('🌐 번역 로드 시작 - 언어 코드: $currentCountryCode');

      currentLabels['profileImage'] = AuthDefaultTranslations.getTranslation('profileImage', currentCountryCode);
      currentLabels['profileDescription'] = AuthDefaultTranslations.getTranslation('profileDescription', currentCountryCode);
      currentLabels['uploadImage'] = AuthDefaultTranslations.getTranslation('uploadImage', currentCountryCode);
      currentLabels['uploadVideo'] = AuthDefaultTranslations.getTranslation('uploadVideo', currentCountryCode);
      currentLabels['uploadedMedia'] = AuthDefaultTranslations.getTranslation('uploadedMedia', currentCountryCode);
      currentLabels['mainPhoto'] = AuthDefaultTranslations.getTranslation('mainPhoto', currentCountryCode);
      currentLabels['imageErrorMsg'] = AuthDefaultTranslations.getTranslation('imageErrorMsg', currentCountryCode);
      currentLabels['videoErrorMsg'] = AuthDefaultTranslations.getTranslation('videoErrorMsg', currentCountryCode);
      currentLabels['firstItemImageError'] = AuthDefaultTranslations.getTranslation('firstItemImageError', currentCountryCode);
      currentLabels['deleteErrorMsg'] = AuthDefaultTranslations.getTranslation('deleteErrorMsg', currentCountryCode);
      currentLabels['upload_guide_title'] = AuthDefaultTranslations.getTranslation('upload_guide_title', currentCountryCode);
      currentLabels['profile_image_guide_title'] = AuthDefaultTranslations.getTranslation('profile_image_guide_title', currentCountryCode);
      currentLabels['profile_image_guide_desc1'] = AuthDefaultTranslations.getTranslation('profile_image_guide_desc1', currentCountryCode);
      currentLabels['profile_image_guide_desc2'] = AuthDefaultTranslations.getTranslation('profile_image_guide_desc2', currentCountryCode);
      currentLabels['intro_video_guide_title'] = AuthDefaultTranslations.getTranslation('intro_video_guide_title', currentCountryCode);
      currentLabels['intro_video_guide_desc1'] = AuthDefaultTranslations.getTranslation('intro_video_guide_desc2', currentCountryCode);
      currentLabels['intro_video_guide_desc2'] = AuthDefaultTranslations.getTranslation('intro_video_guide_desc2', currentCountryCode);
      currentLabels['intro_video_guide_desc3'] = AuthDefaultTranslations.getTranslation('intro_video_guide_desc3', currentCountryCode);
      currentLabels['reward_guide_title'] = AuthDefaultTranslations.getTranslation('reward_guide_title', currentCountryCode);
      currentLabels['reward_guide_desc'] = AuthDefaultTranslations.getTranslation('reward_guide_desc', currentCountryCode);

      print('✅ 번역 로드 완료');
    } catch (e) {
      print('❌ 번역 로드 오류: $e');
    }
  }

  void dispose() {
    profileImageNotifier.dispose();
    profileMediaNotifier.dispose();
    isLoadingNotifier.dispose();
    referralCodeNotifier.dispose();
    mainImageIndexNotifier.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class DocumentUploadController {
  final String uid;
  final FirebaseStorage _storage;
  final ImagePicker _picker = ImagePicker();

  final ValueNotifier<List<String?>> documentImagesNotifier = ValueNotifier<List<String?>>([]);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);

  // 번역 관련
  Map<String, String> currentLabels = {
    "document_upload": "📌 프렌즈 신원확인을 위한 이미지 제출 안내",
    "document_upload_desc": "<제출 이미지>\n1. 신분증 앞면 사진(주민등록증 또는 여권)\n   이름·생년월일·사진이 선명히 보여야 합니다.\n2. 실물 얼굴 사진\n   마스크·선글라스·필터 없이, 밝고 선명하게 촬영",
    "upload_button": "업로드하기",
    "photo_guide": "해당 정보는 운영팀 승인 검토용으로만 사용되며, 허위 제출 시 활동이 제한될 수 있습니다.",
  };

  DocumentUploadController({
    required this.uid,
    FirebaseStorage? storage,
  }) : _storage = storage ?? FirebaseStorage.instance;

  List<String?> get documentImagePaths => documentImagesNotifier.value;
  set documentImagePaths(List<String?> paths) {
    documentImagesNotifier.value = paths;
  }

  bool get isLoading => isLoadingNotifier.value;

  bool hasValidDocuments() {
    return documentImagePaths.any((path) => path != null && path.isNotEmpty);
  }

  Future<void> pickImage() async {
    try {
      isLoadingNotifier.value = true;

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        // 컨트롤러에 경로 저장 (기존 이미지 목록에 추가)
        List<String?> updatedPaths = List<String?>.from(documentImagePaths);
        // null 값 제거 (필터링)
        updatedPaths = updatedPaths.where((path) => path != null && path.isNotEmpty).toList();
        // 새 이미지 추가
        updatedPaths.add(pickedFile.path);
        // 최대 3개로 제한
        if (updatedPaths.length > 3) {
          updatedPaths = updatedPaths.sublist(updatedPaths.length - 3);
        }
        documentImagePaths = updatedPaths;
        print('📄 이미지 추가됨: $documentImagePaths');
      }
    } catch (e) {
      print('Error picking image: $e');
      throw e;
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  void removeImage(int index) {
    List<String?> updatedPaths = List<String?>.from(documentImagePaths);
    // 해당 인덱스 제거
    if (index >= 0 && index < updatedPaths.length) {
      updatedPaths.removeAt(index);
      documentImagePaths = updatedPaths;
      print('📄 이미지 제거됨: $documentImagePaths');
    }
  }

  Future<List<String>> uploadDocumentImages() async {
    List<String> documentImageUrls = [];

    for (int i = 0; i < documentImagePaths.length; i++) {
      final documentPath = documentImagePaths[i];
      if (documentPath != null && documentPath.isNotEmpty) {
        try {
          final File docFile = File(documentPath);

          if (!await docFile.exists()) {
            continue;
          }

          final docStorageRef = _storage
              .ref()
              .child('tripfriends_documents')
              .child(uid)
              .child('document_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg');

          final docUploadTask = docStorageRef.putFile(docFile);
          await docUploadTask.whenComplete(() => null);

          if (docUploadTask.snapshot.state == TaskState.success) {
            final docUrl = await docStorageRef.getDownloadURL();
            documentImageUrls.add(docUrl);
          }
        } catch (e) {
          // 개별 실패는 전체 프로세스를 중단하지 않음
        }
      }
    }

    return documentImageUrls;
  }

  Future<void> loadTranslations(String currentCountryCode) async {
    try {
      final String translationJson = await rootBundle.loadString('assets/data/auth_translations.json');
      final translationData = json.decode(translationJson);

      final translations = translationData['translations'];
      if (translations['document_upload'] != null &&
          translations['document_upload_desc'] != null &&
          translations['upload_button'] != null &&
          translations['photo_guide'] != null) {
        currentLabels = {
          "document_upload": translations['document_upload'][currentCountryCode],
          "document_upload_desc": translations['document_upload_desc'][currentCountryCode],
          "upload_button": translations['upload_button'][currentCountryCode],
          "photo_guide": translations['photo_guide'][currentCountryCode],
        };
      }
    } catch (e) {
      print('Error loading translations: $e');
    }
  }

  void dispose() {
    documentImagesNotifier.dispose();
    isLoadingNotifier.dispose();
  }
}
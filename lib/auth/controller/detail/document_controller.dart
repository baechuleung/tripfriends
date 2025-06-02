import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 문서 데이터 로드
  Future<Map<String, dynamic>?> loadUserDocument(String uid) async {
    try {
      final docSnapshot = await _firestore.collection("tripfriends_users").doc(uid).get();

      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      print('❌ 유저 문서 로드 실패: $e');
      return null;
    }
  }

  // 문서 업데이트
  Future<void> updateUserDocument(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection("tripfriends_users").doc(uid).update(data);
      print('✅ 문서 업데이트 완료');
    } catch (e) {
      print('❌ 문서 업데이트 실패: $e');
      throw e;
    }
  }

  // 특정 필드 값 가져오기
  Future<T?> getFieldValue<T>(String uid, String fieldName, {T? defaultValue}) async {
    try {
      final docSnapshot = await _firestore.collection("tripfriends_users").doc(uid).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data.containsKey(fieldName)) {
          final value = data[fieldName];
          if (value is T) {
            return value;
          }
        }
      }
      return defaultValue;
    } catch (e) {
      print('❌ 필드 값 가져오기 실패: $e');
      return defaultValue;
    }
  }
}
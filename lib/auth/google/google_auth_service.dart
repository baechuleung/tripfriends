import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    final uid = userCredential.user?.uid;
    if (uid == null) return null;

    // ✅ tripfriends_users 컬렉션에서 가입 여부 확인
    final userDoc = await FirebaseFirestore.instance.collection('tripfriends_users').doc(uid).get();
    final isNewUser = !userDoc.exists;

    return {
      'userCredential': userCredential,
      'isNewUser': isNewUser,
    };
  }
}
part of 'package:aroosi_flutter/core/firebase_service.dart';

extension FirebaseServiceAuth on FirebaseService {
  Future<fb.UserCredential> signInWithApple({
    String? idToken,
    String? accessToken,
  }) async {
    final credential = fb.OAuthProvider('apple.com').credential(
      idToken: idToken,
      accessToken: accessToken,
    );
    return _authInstance.signInWithCredential(credential);
  }

  Future<fb.UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _authInstance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<fb.UserCredential> createEmailPasswordUser({
    required String email,
    required String password,
    required String name,
  }) async {
    final userCredential = await _authInstance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await userCredential.user?.updateDisplayName(name);
    return userCredential;
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _authInstance.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() {
    return _authInstance.signOut();
  }

  Future<void> deleteAccount() async {
    await currentUser?.delete();
  }
}

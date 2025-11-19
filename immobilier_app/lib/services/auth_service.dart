import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  bool get isSignedIn => currentUser != null;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    notifyListeners();
    return cred;
  }

  Future<UserCredential> signUpWithEmail(String email, String password, {String? displayName, String? phone}) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    // Update displayName
    if (displayName != null) {
      await cred.user?.updateDisplayName(displayName);
    }
    // create user document
    await _db.collection('users').doc(cred.user?.uid).set({
      'email': email,
      'displayName': displayName ?? '',
      'phone': phone ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
    notifyListeners();
    return cred;
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> changePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');
    await user.updatePassword(newPassword);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}

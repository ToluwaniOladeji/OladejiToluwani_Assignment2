import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/validators.dart';

/// All Firebase Auth + user-profile access lives here. Screens never touch
/// FirebaseAuth directly.
class AuthRepository {
  AuthRepository(this._auth, this._db);
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> register(String name, String email, String password) async {
    if (!Validators.isAluEmail(email)) {
      throw FirebaseAuthException(
        code: 'invalid-domain',
        message: 'Please use your ALU email address.',
      );
    }
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user!;
    await user.updateDisplayName(name.trim());
    await user.sendEmailVerification();
    await _db.collection('users').doc(user.uid).set({
      'email': email.trim().toLowerCase(),
      'displayName': name.trim(),
      'role': 'student', // staff are promoted manually in the Console
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> login(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> resendVerification() async =>
      _auth.currentUser?.sendEmailVerification();

  /// Reloads the user and refreshes the ID token so Firestore rules see
  /// `email_verified == true`. Returns the new verification state.
  Future<bool> refreshVerification() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    await _auth.currentUser?.getIdToken(true);
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<String> fetchRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return (doc.data()?['role'] as String?) ?? 'student';
  }

  Future<void> logout() => _auth.signOut();
}

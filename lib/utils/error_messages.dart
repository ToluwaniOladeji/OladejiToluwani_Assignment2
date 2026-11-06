import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// Turns exceptions into short, user-friendly messages.
String errorMessage(Object e) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'invalid-domain':
        return e.message ?? 'Please use your ALU email address.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
  if (e is FirebaseException) {
    if (e.code == 'permission-denied' || e.code == 'unauthorized') {
      return 'You do not have permission to do that.';
    }
    return e.message ?? 'A server error occurred.';
  }
  return 'Something went wrong. Please try again.';
}

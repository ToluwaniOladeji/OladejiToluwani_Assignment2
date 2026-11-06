/// Email domains allowed to use the app. Adjust to your institution.
const allowedEmailDomains = ['alustudent.com', 'alueducation.com'];

class Validators {
  static bool isAluEmail(String email) {
    final e = email.trim().toLowerCase();
    return allowedEmailDomains.any((d) => e.endsWith('@$d'));
  }

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Registration: must be a valid ALU address.
  static String? aluEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(v.trim())) return 'Enter a valid email address';
    if (!isAluEmail(v)) return 'Use your ALU email address';
    return null;
  }

  /// Login: just needs to look like an email (server decides the rest).
  static String? loginEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Use at least 8 characters';
    return null;
  }

  static String? required(String? v, String field, {int min = 1}) {
    if (v == null || v.trim().length < min) {
      return min <= 1
          ? '$field is required'
          : '$field must be at least $min characters';
    }
    return null;
  }
}

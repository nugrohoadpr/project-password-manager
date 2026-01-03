class PasswordItem {
  final int id;
  final String title;
  final String email;
  final String password;
  final String website;
  final String firstLetter;

  PasswordItem({
    required this.id,
    required this.title,
    required this.email,
    required this.password,
    required this.website,
  }) : firstLetter = title.isNotEmpty ? title[0].toUpperCase() : '?';

  // Helper: cek apakah password lemah
  bool get isWeak {
    return password.length < 8 ||
        !password.contains(RegExp(r'[A-Z]')) ||
        !password.contains(RegExp(r'[0-9]')) ||
        !password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  // Helper: strength label
  String get strengthLabel {
    return isWeak ? 'Weak' : 'Strong';
  }
}

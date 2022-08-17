class User {
  final String name;
  final String email;

  User({required this.email}) : name = userNameFromEmail(email);
  static String userNameFromEmail(String email) {
    return RegExp(r'([^@]+)').firstMatch(email)![0]!;
  }
}

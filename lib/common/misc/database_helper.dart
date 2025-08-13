String emailToPath(String email) {
  var reducedEmail = email.replaceAll('@', '__at__');
  reducedEmail = reducedEmail.replaceAll('.', '__dot__');
  return reducedEmail;
}

String pathToEmail(String reducedEmail) {
  var email = reducedEmail.replaceAll('__at__', '@');
  email = email.replaceAll('__dot__', '.');
  return email;
}

// We need this because before septembre 2025, this field did not exist
final defaultCreationDate = DateTime(2024, 9, 1).toIso8601String();
final DateTime isActiveLimitDate =
    DateTime(DateTime.now().year).add(const Duration(days: 30 * 7));

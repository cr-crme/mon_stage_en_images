extension EmailValidator on String {
  bool isValidEmail() {
    final emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    final regex = RegExp(emailPattern);
    return regex.hasMatch(this);
  }
}

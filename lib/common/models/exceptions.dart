class NotImplemented implements Exception {
  final String message;

  const NotImplemented(this.message);
}

class NotLoggedIn implements Exception {
  final String message = 'User must be logged in';

  const NotLoggedIn();
}

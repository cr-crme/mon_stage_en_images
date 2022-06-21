class TypeException implements Exception {
  final String message;

  const TypeException(this.message);
}

class ValueException implements Exception {
  final String message;

  const ValueException(this.message);
}

class ShouldNotCall implements Exception {
  final String message;

  const ShouldNotCall(this.message);
}

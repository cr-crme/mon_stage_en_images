import 'dart:math';

class Student {
  final String id;
  final String firstName;
  final String lastName;

  final int progression;

  Student({
    required this.firstName,
    required this.lastName,
    required this.progression,
  }) : id = Random().hashCode.toString();

  @override
  String toString() {
    return '$firstName $lastName';
  }
}

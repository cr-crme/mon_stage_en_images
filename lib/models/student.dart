import 'dart:math';

class Student {
  final String id;
  final String firstName;
  final String lastName;

  Student({required this.firstName, required this.lastName})
      : id = Random().hashCode.toString();
}

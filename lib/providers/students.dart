import 'package:flutter/foundation.dart';

import '../models/exceptions.dart';
import '../models/student.dart';

bool isInteger(num value) => (value % 1) == 0;

class Students with ChangeNotifier {
  final List<Student> _students = [];

  void add(Student student, {bool notify = true}) {
    _students.add(student);
    if (notify) notifyListeners();
  }

  Student operator [](value) {
    if (value is int) {
      return _students[value];
    } else if (value is String) {
      return _students[getIndex(value)];
    } else {
      throw const TypeException('Wrong type for getting a student');
    }
  }

  int getIndex(String id) {
    return _students.indexWhere((element) => element.id == id);
  }

  int get count => _students.length;
}

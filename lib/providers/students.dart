import './provided_list.dart';
import '../models/student.dart';

class Students extends ProvidedList<Student> {
  int get count => length;

  @override
  Student deserializeItem(map) {
    return Student.fromSerialized(map);
  }
}

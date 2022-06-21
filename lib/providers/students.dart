import 'list_provided.dart';
import '../models/student.dart';

class Students extends ListProvided<Student> {
  int get count => length;

  @override
  Student deserializeItem(map) {
    return Student.fromSerialized(map);
  }
}

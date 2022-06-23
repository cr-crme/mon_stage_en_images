import '../models/student.dart';
import '../../misc/custom_containers/list_provided.dart';

class Students extends ListProvided<Student> {
  int get count => length;

  @override
  Student deserializeItem(map) {
    return Student.fromSerialized(map);
  }
}
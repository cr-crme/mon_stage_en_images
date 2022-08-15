import 'package:defi_photo/crcrme_enhanced_containers/lib/list_provided.dart';

import '../models/question.dart';
import '../models/student.dart';

class AllStudents extends ListProvided<Student> {
  int get count => length;

  @override
  Student deserializeItem(data) {
    return Student.fromSerialized(data);
  }

  bool isQuestionActiveForAll(Question question) {
    return indexWhere(
          (s) {
            final answer = s.allAnswers[question];
            return answer == null ? false : !answer.isActive;
          },
        ) <
        0;
  }
}

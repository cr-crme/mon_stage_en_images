import 'package:defi_photo/crcrme_enhanced_containers/lib/firebase_list_provided.dart';

import '../models/question.dart';
import '../models/student.dart';

class AllStudents extends FirebaseListProvided<Student> {
  int get count => length;

  AllStudents() : super(availableIdsPath: 'students-id', dataPath: 'students');

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

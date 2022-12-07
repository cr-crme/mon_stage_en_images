import 'package:enhanced_containers/enhanced_containers.dart';

import '../models/answer.dart';
import '../models/question.dart';
import '../models/student.dart';

class AllStudents extends FirebaseListProvided<Student>
    with ItemsWithCreationTimed {
  int get count => length;
  static const String dataName = 'students';

  AllStudents()
      : super(
          pathToData: dataName,
          pathToAvailableDataIds: '$dataName-generic',
        );

  @override
  Student deserializeItem(data) {
    return Student.fromSerialized(data);
  }

  @override
  set pathToAvailableDataIds(String newPath) {
    super.pathToAvailableDataIds = '$dataName-$newPath';
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

  void setAnswer({
    required Student student,
    required Question question,
    required Answer answer,
  }) {
    student.allAnswers[question] = answer;
    replace(student);
    notifyListeners();
  }
}

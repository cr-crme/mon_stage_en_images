import './all_students.dart';
import '../models/answer.dart';
import '../models/question.dart';
import '../models/enum.dart';
import '../models/section.dart';
import '../models/student.dart';
import '../../misc/custom_containers/list_provided.dart';

class AllQuestions extends ListProvided<Question> with Section {
  // Constructors and (de)serializer
  AllQuestions() : super();
  AllQuestions.fromSerialized(map) : super.fromSerialized(map);

  @override
  Question deserializeItem(map) {
    return Question.fromSerialized(map);
  }

  AllQuestions fromSection(index) {
    final out = AllQuestions();
    forEach((question) {
      if (question.section == index) out.add(question);
    });
    return out;
  }

  void addToAll(Question question,
      {bool notify = true,
      required AllStudents students,
      Student? currentStudent}) {
    super.add(question, notify: notify);

    for (var student in students) {
      final isActive = question.defaultTarget != Target.none &&
          (question.defaultTarget == Target.all ||
              currentStudent == null ||
              student.id == currentStudent.id);
      student.allAnswers[question] = Answer(
          status: isActive
              ? AnswerStatus.needStudentAction
              : AnswerStatus.deactivated,
          discussion: []);
    }
  }

  // Attributes and methods
  int get number => length;
}

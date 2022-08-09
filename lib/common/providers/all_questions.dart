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

  AllQuestions fromSection(int index) {
    final out = AllQuestions();
    forEach((question) {
      if (question.section == index) out.add(question);
    });
    return out;
  }

  void addToAll(
    Question question, {
    bool notify = true,
    required AllStudents students,
    Student? currentStudent,
  }) {
    super.add(question, notify: notify);

    for (var student in students) {
      final isActive = question.defaultTarget != Target.none &&
          (question.defaultTarget == Target.all ||
              currentStudent == null ||
              student.id == currentStudent.id);
      student.allAnswers[question] = Answer(
          isActive: isActive,
          actionRequired: ActionRequired.fromStudent,
          discussion: []);
    }
  }

  void modifyToAll(
    Question question, {
    bool notify = true,
    required AllStudents students,
    Student? currentStudent,
  }) {
    replace(question, notify: notify);

    for (var student in students) {
      var answer = student.allAnswers[question]!;
      student.allAnswers[question] = answer.copyWith(
          actionRequired: answer.isActive
              ? ActionRequired.fromStudent
              : ActionRequired.none);
    }
  }

  void removeToAll(
    Question question, {
    bool notify = true,
    required AllStudents students,
  }) {
    remove(question, notify: notify);

    for (var student in students) {
      student.allAnswers.remove(question);
    }
  }

  // Attributes and methods
  int get number => length;
}

import 'package:defi_photo/crcrme_enhanced_containers/lib/firebase_list_provided.dart';
import './all_students.dart';
import '../models/answer.dart';
import '../models/enum.dart';
import '../models/question.dart';
import '../models/section.dart';
import '../models/student.dart';

class AllQuestions extends FirebaseListProvided<Question> with Section {
  // Constructors and (de)serializer
  AllQuestions()
      : super(availableIdsPath: 'questions-id', dataPath: 'questions');

  @override
  Question deserializeItem(data) {
    return Question.fromSerialized(data);
  }

  List<Question> fromSection(int index) {
    List<Question> out =
        where((question) => question.section == index).toList(growable: false);
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
      students.setAnswer(
          student: student,
          question: question,
          answer: Answer(
              isActive: isActive, actionRequired: ActionRequired.fromStudent));
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
      final answer = student.allAnswers[question]!;
      students.setAnswer(
          student: student,
          question: question,
          answer: answer.copyWith(
              actionRequired: answer.isActive
                  ? ActionRequired.fromStudent
                  : ActionRequired.none));
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

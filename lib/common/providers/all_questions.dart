import 'package:enhanced_containers/enhanced_containers.dart';

import '../models/answer.dart';
import '../models/enum.dart';
import '../models/question.dart';
import '../models/section.dart';
import '../models/student.dart';
import 'all_students.dart';

class AllQuestions extends FirebaseListProvided<Question> with Section {
  // Constructors and (de)serializer
  static const String dataName = 'questions';

  AllQuestions()
      : super(
          pathToData: dataName,
          pathToAvailableDataIds: '$dataName-generic',
        );

  @override
  Question deserializeItem(data) {
    return Question.fromSerialized(data);
  }

  List<Question> fromSection(int index) {
    List<Question> out =
        where((question) => question.section == index).toList(growable: false);
    return out;
  }

  @override
  set pathToAvailableDataIds(String newPath) {
    super.pathToAvailableDataIds = '$dataName-$newPath';
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
    Map<Student, bool>? isActive,
  }) {
    replace(question, notify: notify);

    for (var student in students) {
      final answer = student.allAnswers[question]!;
      students.setAnswer(
          student: student,
          question: question,
          answer: answer.copyWith(
              isActive:
                  isActive != null ? isActive[student] : answer.isActive));
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

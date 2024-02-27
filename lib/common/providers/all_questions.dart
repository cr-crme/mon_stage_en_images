import 'package:defi_photo/common/models/user.dart';
import 'package:defi_photo/common/providers/all_answers.dart';
import 'package:enhanced_containers/enhanced_containers.dart';

import '../models/answer.dart';
import '../models/enum.dart';
import '../models/question.dart';
import '../models/section.dart';

class AllQuestions extends FirebaseListProvided<Question> with Section {
  // Constructors and (de)serializer
  static const String dataName = 'questions';

  AllQuestions()
      : super(
          pathToData: dataName,
          pathToAvailableDataIds: '$dataName-generic', // TODO: Remove -generic
        );

  @override
  Question deserializeItem(data) {
    return Question.fromSerialized(data);
  }

  ///
  /// Returns the list of questions from a section
  /// [index] is the index of the section
  List<Question> fromSection(int index) {
    List<Question> out =
        where((question) => question.section == index).toList(growable: false);
    return out;
  }

  @override
  set pathToAvailableDataIds(String? newPath) =>
      super.pathToAvailableDataIds = '$dataName-$newPath';

  ///
  /// Adds a question to all the students
  /// [question] is the question to add
  /// [answers] is the list of answers
  /// [currentUser] is the current user
  /// [currentStudent] is the current student
  /// [isActive] is the map of the students and if the question is active for them
  /// [notify] is if the listeners should be notified
  void addToAll(
    Question question, {
    required AllAnswers answers,
    required User currentUser,
    User? currentStudent,
    Map<String, bool>? isActive,
    bool notify = true,
  }) {
    super.add(question, notify: notify);

    for (var answer in answers.fromStudent(currentStudent?.id)) {
      if (currentStudent != null && answer.studentId != currentStudent.id) {
        continue;
      }

      final isActiveForStudent = isActive == null
          ? question.defaultTarget != Target.none &&
              (question.defaultTarget == Target.all ||
                  currentStudent == null ||
                  answer.studentId == currentStudent.id)
          : isActive[answer.studentId]!;

      answers.add(Answer(
          isActive: isActiveForStudent,
          questionId: question.id,
          createdById: currentUser.id,
          studentId: answer.studentId,
          actionRequired: ActionRequired.fromStudent));
    }
  }

  ///
  /// Modifies a question to all the students
  /// [question] is the question to modify<>
  /// [answers] is the list of answers
  /// [currentUser] is the current user
  /// [currentStudent] is the current student
  /// [isActive] is the map of the students and if the question is active for them
  /// [notify] is if the listeners should be notified
  void modifyToAll(
    Question question, {
    required AllAnswers answers,
    required User currentUser,
    User? currentStudent,
    Map<String, bool>? isActive,
    bool notify = true,
  }) {
    replace(question, notify: notify);

    for (var answer in answers) {
      if (currentStudent != null && answer.studentId != currentStudent.id) {
        continue;
      }

      answers.replace(answer.copyWith(
          isActive:
              isActive == null ? answer.isActive : isActive[answer.studentId]));
    }
  }

  ///
  /// Removes a question to all the students
  /// [question] is the question to remove
  /// [answers] is the list of answers
  /// [notify] is if the listeners should be notified
  void removeToAll(
    Question question, {
    required AllAnswers answers,
    bool notify = true,
  }) {
    remove(question, notify: notify);
    answers.removeQuestion(question);
  }

  ///
  /// Returns the number of questions in the list
  int get number => length;
}

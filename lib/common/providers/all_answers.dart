import 'package:defi_photo/common/models/answer.dart';
import 'package:defi_photo/common/models/database.dart';
import 'package:defi_photo/common/models/enum.dart';
import 'package:defi_photo/common/models/exceptions.dart';
import 'package:defi_photo/common/models/question.dart';
import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllAnswers extends FirebaseListProvided<StudentAnswers> {
  int get count => length;
  static const String dataName = 'answers';

  AllAnswers() : super(pathToData: dataName);

  @override
  StudentAnswers deserializeItem(data) {
    return StudentAnswers.fromSerialized(data);
  }

  @override
  set pathToAvailableDataIds(String? newPath) =>
      throw 'Id should not be used for students';

  ///
  /// Returns if the question is active for all the students who has it
  bool isQuestionActiveForAll(Question question) => every((a) {
        final index = a.answers.indexWhere((q) => q.questionId == question.id);
        // If the question does not exist for that student, it is technically not inactive
        if (index == -1) return true;
        return a.answers[index].isActive;
      });

  ///
  /// Returns if the question is inactive for all the students who has it
  bool isQuestionInactiveForAll(Question question) => every((a) {
        final index = a.answers.indexWhere((q) => q.questionId == question.id);
        // If the question does not exist for that student, it is technically not inactive
        if (index == -1) return true;
        return !a.answers[index].isActive;
      });

  ///
  /// Returns the number of answers in the list
  int get number => length;

  ///
  /// Returns the number of active answers in the list
  /// [answers] is the list of answers to check
  static int numberActiveFrom(Iterable<Answer> answers) =>
      answers.fold(0, (int prev, e) => prev + (e.isActive ? 1 : 0));

  ///
  /// Returns the number of answered answers in the list
  /// [answers] is the list of answers to check
  static int numberAnsweredFrom(Iterable<Answer> answers) =>
      answers.fold(0, (int prev, e) => prev + (e.isAnswered ? 1 : 0));

  @override
  void add(StudentAnswers item, {bool notify = true, bool cacheItem = false}) =>
      throw 'Use the addAnswer method instead';

  @override
  void replace(StudentAnswers item, {bool notify = true}) =>
      throw 'Use the addAnswer method instead';

  void addAnswer(Answer answer, {bool notify = true}) {
    final studentAnswers = firstWhereOrNull((e) => e.id == answer.studentId);
    if (studentAnswers == null) {
      super.add(StudentAnswers([answer], studentId: answer.studentId),
          notify: notify, cacheItem: true);
    } else {
      final index = studentAnswers.answers
          .indexWhere((e) => e.questionId == answer.questionId);
      if (index != -1) {
        studentAnswers.answers[index] = answer;
      } else {
        studentAnswers.answers.add(answer);
      }
      super.replace(studentAnswers, notify: notify);
    }

    notifyListeners();
  }

  ///
  /// Returns the number of actions required from the user
  /// [context] is required to get the current user
  /// [answers] is the list of answers to check
  static int numberOfActionsRequiredFrom(
      Iterable<Answer> answers, BuildContext context) {
    final userType =
        Provider.of<Database>(context, listen: false).currentUser!.userType;
    if (userType == UserType.student) {
      return numberNeedStudentActionFrom(answers, context);
    } else if (userType == UserType.teacher) {
      return numberNeedTeacherActionFrom(answers, context);
    } else {
      throw const NotLoggedIn();
    }
  }

  ///
  /// Returns the number of actions required from the teacher
  /// [answers] is the list of answers to check
  /// [ctx] is required to get the current user
  static int numberNeedTeacherActionFrom(
          Iterable<Answer> answers, BuildContext ctx) =>
      answers.fold(
          0,
          (int prev, e) =>
              prev + (e.action(ctx) == ActionRequired.fromTeacher ? 1 : 0));

  ///
  /// Returns the number of actions required from the student
  /// [answers] is the list of answers to check
  /// [context] is required to get the current user
  static int numberNeedStudentActionFrom(
          Iterable<Answer> answers, BuildContext context) =>
      answers.fold(
          0,
          (int prev, e) =>
              prev + (e.action(context) == ActionRequired.fromStudent ? 1 : 0));

  ///
  /// Returns the answers filtered by the [questionIds], [studentIds], [isActive] and [isAnswered]
  /// [questionIds] is the list of questions
  /// [studentIds] is the list of student ids
  /// [isActive] is if the answer is active
  /// [isAnswered] is if the answer is answered
  Iterable<Answer> filter({
    Iterable<String>? questionIds,
    Iterable<String>? studentIds,
    bool? isActive,
    bool? isAnswered,
    bool? hasAnswer,
  }) =>
      expand((e) => e.answers.where((q) =>
          (questionIds == null || questionIds.contains(q.questionId)) &&
          (studentIds == null || studentIds.contains(q.studentId)) &&
          (isActive == null || q.isActive == isActive) &&
          (isAnswered == null || q.isAnswered == isAnswered) &&
          (hasAnswer == null || q.hasAnswer == hasAnswer)));

  ///
  /// Removes the answers associated with the [question]
  /// [question] is the question
  void removeQuestion(Question question) {
    for (final student in this) {
      final toRemove =
          student.answers.where((e) => e.questionId == question.id);
      toRemove.forEach(student.answers.remove);
      replace(student, notify: true);
    }
    notifyListeners();
  }
}

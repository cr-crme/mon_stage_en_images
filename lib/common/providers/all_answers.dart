import 'package:mon_stage_en_images/common/models/answer.dart';
import 'package:mon_stage_en_images/common/models/database.dart';
import 'package:mon_stage_en_images/common/models/enum.dart';
import 'package:mon_stage_en_images/common/models/question.dart';
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
  void add(StudentAnswers item, {bool notify = true}) =>
      throw 'Use the addAnswer method instead';

  @override
  Future<void> replace(StudentAnswers item, {bool notify = true}) =>
      throw 'Use the addAnswer method instead';

  Future<StudentAnswers> getOrSetStudentAnswers(String studentId,
      {int maxRetry = 10}) async {
    final studentAnswers = firstWhereOrNull((e) => e.id == studentId);
    if (studentAnswers != null) return studentAnswers;

    super.add(StudentAnswers([], studentId: studentId));

    while (true) {
      // Wait for the database to be updated
      await Future.delayed(const Duration(milliseconds: 100));

      final studentAnswers = firstWhereOrNull((e) => e.id == studentId);
      if (studentAnswers != null) return studentAnswers;

      maxRetry--;
      if (maxRetry == 0) throw 'Could not add the new student';
    }
  }

  Future<void> addAnswers(Iterable<Answer> answers,
      {bool notify = true}) async {
    final Map<String, StudentAnswers> studentAnswers = {};
    for (final answer in answers) {
      if (!studentAnswers.keys.contains(answer.studentId)) {
        // Get (or create) all the required StudentAnswers
        studentAnswers[answer.studentId] =
            await getOrSetStudentAnswers(answer.studentId);
      }

      final index = studentAnswers[answer.studentId]!
          .answers
          .indexWhere((e) => e.questionId == answer.questionId);
      if (index != -1) {
        studentAnswers[answer.studentId]!.answers[index] = answer;
      } else {
        studentAnswers[answer.studentId]!.answers.add(answer);
      }
    }

    for (final studentAnswer in studentAnswers.values) {
      await super.replace(studentAnswer, notify: notify);
    }

    if (notify) notifyListeners();
  }

  void modifyAnswer(Answer answer, {bool notify = true}) =>
      addAnswers([answer], notify: notify);

  ///
  /// Returns the number of actions required from the user
  /// [context] is required to get the current user
  /// [answers] is the list of answers to check
  static int numberOfActionsRequiredFrom(
      Iterable<Answer> answers, BuildContext context) {
    final userType =
        Provider.of<Database>(context, listen: false).currentUser?.userType ??
            UserType.none;
    if (userType == UserType.student) {
      return numberNeedStudentActionFrom(answers, context);
    } else if (userType == UserType.teacher) {
      return numberNeedTeacherActionFrom(answers, context);
    } else {
      return 0;
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

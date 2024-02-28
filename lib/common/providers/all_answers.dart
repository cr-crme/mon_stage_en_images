import 'package:defi_photo/common/models/database.dart';
import 'package:defi_photo/common/models/enum.dart';
import 'package:defi_photo/common/models/exceptions.dart';
import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/answer.dart';
import '../models/question.dart';

class AllAnswers extends FirebaseListProvided<Answer> {
  int get count => length;
  static const String dataName = 'answers';

  AllAnswers() : super(pathToData: dataName);

  @override
  Answer deserializeItem(data) {
    return Answer.fromSerialized(data);
  }

  @override
  set pathToAvailableDataIds(String? newPath) =>
      throw 'Id should not be used for students';

  ///
  /// Returns if the question is active for all the students who has it
  bool isQuestionActiveForAll(Question question) {
    final questions = where((e) => e.questionId == question.id);
    return questions.every((e) => e.isActive);
  }

  ///
  /// Returns if the question is inactive for all the students who has it
  bool isQuestionInactiveForAll(Question question) {
    final questions = where((e) => e.questionId == question.id);
    return questions.every((e) => !e.isActive);
  }

  ///
  /// Returns the number of answers in the list
  int get number => length;

  ///
  /// Returns the number of active answers in the list
  /// [answers] is the list of answers to check
  static int numberActiveFrom(Iterable<Answer> answers) =>
      answers.fold(0, (int prev, e) => prev + (e.isActive ? 1 : 0));

  ///
  /// Returns the number of active answers in the list
  /// It does it from the current list
  int get numberActive => numberActiveFrom(this);

  ///
  /// Returns the number of answered answers in the list
  /// [answers] is the list of answers to check
  static int numberAnsweredFrom(Iterable<Answer> answers) =>
      answers.fold(0, (int prev, e) => prev + (e.isAnswered ? 1 : 0));

  ///
  /// Returns the number of answered answers in the list
  /// It does it from the current list
  int get numberAnswered => numberAnsweredFrom(this);

  @override
  void add(Answer item, {bool notify = true}) {
    // TODO check to add only if the answer does not exist
    super.add(item, notify: notify);
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
  /// Returns the number of actions required from the user
  /// [context] is required to get the current user
  int numberOfActionsRequired(BuildContext context) =>
      numberOfActionsRequiredFrom(this, context);

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
  /// Returns the number of actions required from the teacher
  /// [context] is required to get the current user
  int numberNeedTeacherAction(BuildContext context) =>
      numberNeedTeacherActionFrom(this, context);

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
  /// Returns the number of actions required from the student
  /// [context] is required to get the current user
  int numberNeedStudentAction(BuildContext context) =>
      numberNeedStudentActionFrom(this, context);

  ///
  /// Returns the ansers associated with the [studentId]
  /// [studentId] is the id of the student
  /// If [studentId] is null, all answers are returned
  Iterable<Answer> fromStudent(String? studentId) {
    return where((e) => (studentId == null || e.studentId == studentId));
  }

  ///
  /// Returns the answers associated with the [questions]
  /// [questions] is the list of questions
  /// [studentId] is the id of the student
  /// If [studentId] is null, it is not taken into account
  Iterable<Answer> fromQuestions(Iterable<Question> questions,
      [String? studentId]) {
    final questionIds = questions.map((e) => e.id);
    return where((e) =>
        questionIds.contains(e.questionId) &&
        (studentId == null || e.studentId == studentId));
  }

  ///
  /// Returns the answers associated with the [question]
  /// [question] is the question
  Iterable<Answer> fromQuestion(Question question) {
    return where((e) => e.questionId == question.id);
  }

  ///
  /// Returns the answer associated with the [question] and the [studentId]
  /// [question] is the question
  /// [studentId] is the id of the student
  /// If [studentId] is null, it is not taken into account
  Answer? fromQuestionAndStudent(Question question, String? studentId) {
    return firstWhereOrNull((e) =>
        e.questionId == question.id &&
        (studentId == null || e.studentId == studentId));
  }

  ///
  /// Returns the active answers associated with the [questions]
  /// [questions] is the list of questions
  Iterable<Question> selectActiveQuestionsFrom(Iterable<Question> questions) {
    final questionIds =
        selectActiveAnswersFrom(questions).map((e) => e.questionId);
    return questions.where((e) => questionIds.contains(e.id));
  }

  ///
  /// Returns the active answers associated with the [questions]
  /// [questions] is the list of questions
  Iterable<Answer> selectActiveAnswersFrom(Iterable<Question> questions) =>
      where((e) => e.isActive);

  ///
  /// Removes the answers associated with the [question]
  /// [question] is the question
  void removeQuestion(Question question) {
    final toRemove = where((e) => e.questionId == question.id);
    toRemove.forEach(remove);
  }
}

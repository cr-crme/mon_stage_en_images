import 'package:defi_photo/common/models/discussion.dart';
import 'package:defi_photo/common/widgets/are_you_sure_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/all_answers.dart';
import '../models/answer.dart';
import '../models/company.dart';
import '../models/enum.dart';
import '../models/message.dart';
import '../models/question.dart';
import '../models/student.dart';
import '../providers/login_information.dart';
import '../providers/all_questions.dart';
import '../providers/all_students.dart';
import '../../../../screens/login/login_screen.dart';

class DatabaseClearerOptions {
  const DatabaseClearerOptions({
    this.allowClearing = false,
    this.populateWithDummyData = false,
  });

  final bool allowClearing;
  final bool populateWithDummyData;
}

class DatabaseClearer extends StatefulWidget {
  const DatabaseClearer({
    super.key,
    required this.child,
    required this.options,
    this.title,
    this.onTap,
    this.iconColor,
  });

  final Widget child;
  final DatabaseClearerOptions options;
  final String? title;
  final VoidCallback? onTap;
  final MaterialColor? iconColor;

  @override
  State<DatabaseClearer> createState() => _DatabaseClearerState();
}

class _DatabaseClearerState extends State<DatabaseClearer> {
  late LoginInformation _login;
  late AllStudents _students;
  late AllQuestions _questions;

  void _clear() async {
    if (await _confirm()) {
      _clearAll();
    }
  }

  Future<bool> _confirm() async {
    final sure = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AreYouSureDialog(
          title: 'Suppression de la base de donnée',
          content:
              'Êtes-vous certain(e) de vouloir supprimer toute la base de donnée?',
        );
      },
    );
    return sure != null && sure;
  }

  void _clearAll() {
    _login.userDatabase.deleteUsersInfo();
    _questions.clear(confirm: true);
    _students.clear(confirm: true);

    if (widget.options.populateWithDummyData) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _addDummyData());
    } else {
      _switchToMainLoginPage();
    }
  }

  void _addDummyData() {
    _students.add(
      Student(
        firstName: 'Benjamin',
        lastName: 'Michaud',
        email: 'bb@bb.bb',
        company: Company(name: 'Ici'),
        allAnswers: AllAnswers(questions: []),
      ),
    );
    _students.add(
      Student(
        firstName: 'Aurélie',
        lastName: 'Tondoux',
        email: 'cc@cc.cc',
        company: Company(name: 'Coucou'),
        allAnswers: AllAnswers(questions: []),
      ),
    );

    _questions.add(Question('Photo 1', section: 0, defaultTarget: Target.all));
    _questions.add(Question('Texte 1', section: 0, defaultTarget: Target.none));
    _questions.add(Question('Texte 2', section: 1, defaultTarget: Target.none));
    _questions.add(Question('Photo 2', section: 2, defaultTarget: Target.none));
    _questions.add(Question('Photo 3', section: 3, defaultTarget: Target.none));
    _questions.add(Question('Photo 4', section: 4, defaultTarget: Target.none));
    _questions.add(Question('Photo 5', section: 5, defaultTarget: Target.none));
    _questions.add(Question('Texte 3', section: 5, defaultTarget: Target.all));
    _questions.add(Question('Photo 6', section: 5, defaultTarget: Target.all));

    // We must wait that the questions are actually added to the database
    // before addind answers
    WidgetsBinding.instance.addPostFrameCallback((_) => _answerQuestions());
  }

  void _answerQuestions({int currentQuestion = 0}) {
    _students = Provider.of<AllStudents>(context, listen: false);
    _questions = Provider.of<AllQuestions>(context, listen: false);

    // Wait until student is ready to complete
    if (_students.length != 2 || _questions.length != 9) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _answerQuestions());
      return;
    }

    final benjamin = _students[0];
    if (currentQuestion == 0) {
      _students.setAnswer(
          student: benjamin,
          question: _questions.fromSection(0)[1],
          answer: Answer(actionRequired: ActionRequired.fromStudent));
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _answerQuestions(currentQuestion: 1));
      return;
    }
    if (currentQuestion == 1) {
      _students.setAnswer(
          student: benjamin,
          question: _questions.fromSection(1)[0],
          answer: Answer(
              discussion: Discussion.fromList([
                Message(
                    name: benjamin.firstName,
                    text: "Coucou",
                    creatorId: benjamin.id)
              ]),
              actionRequired: ActionRequired.fromTeacher));
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _answerQuestions(currentQuestion: 2));
      return;
    }
    if (currentQuestion == 2) {
      _students.setAnswer(
          student: benjamin,
          question: _questions.fromSection(5)[1],
          answer: Answer(actionRequired: ActionRequired.fromStudent));
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _answerQuestions(currentQuestion: 3));
      return;
    }
    if (currentQuestion == 3) {
      _students.setAnswer(
          student: benjamin,
          question: _questions.fromSection(5)[1],
          answer: Answer(isValidated: true));
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _answerQuestions(currentQuestion: 4));
      return;
    }
    if (currentQuestion == 4) {
      _students.setAnswer(
          student: benjamin,
          question: _questions.fromSection(5)[2],
          answer: Answer(
              discussion: Discussion.fromList([
                Message(
                    name: benjamin.firstName,
                    text: "Coucou",
                    creatorId: benjamin.id)
              ]),
              actionRequired: ActionRequired.fromTeacher));
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _answerQuestions(currentQuestion: 5));
      return;
    }

    final aurelie = _students[1];
    if (currentQuestion == 5) {
      _students.setAnswer(
          student: aurelie,
          question: _questions.fromSection(5)[2],
          answer: Answer(
              actionRequired: ActionRequired.fromTeacher,
              discussion: Discussion.fromList([
                Message(
                    name: 'Prof', text: 'Coucou', creatorId: _login.user!.id),
                Message(
                    name: 'Aurélie',
                    text: 'Non pas coucou',
                    creatorId: aurelie.id),
                Message(
                    name: 'Prof', text: 'Coucou', creatorId: _login.user!.id),
                Message(
                    name: 'Aurélie',
                    text:
                        'https://cdn.photographycourse.net/wp-content/uploads/2014/11/'
                        'Landscape-Photography-steps.jpg',
                    isPhotoUrl: true,
                    creatorId: aurelie.id),
                Message(
                    name: 'Prof', text: 'Coucou', creatorId: _login.user!.id),
                Message(
                    name: 'Aurélie',
                    text: 'Non pas coucou',
                    creatorId: aurelie.id),
                Message(
                    name: 'Prof', text: 'Coucou', creatorId: _login.user!.id),
                Message(
                    name: 'Aurélie',
                    text: 'Non pas coucou',
                    creatorId: aurelie.id),
                Message(
                    name: 'Prof', text: 'Coucou', creatorId: _login.user!.id),
                Message(
                    name: 'Aurélie',
                    text: 'Non pas coucou',
                    creatorId: aurelie.id),
                Message(
                    name: 'Prof', text: 'Coucou', creatorId: _login.user!.id),
                Message(
                    name: 'Aurélie',
                    text:
                        'https://cdn.photographycourse.net/wp-content/uploads/2014/11/'
                        'Landscape-Photography-steps.jpg',
                    isPhotoUrl: true,
                    creatorId: aurelie.id),
                Message(
                    name: 'Prof', text: 'Coucou', creatorId: _login.user!.id),
                Message(
                    name: 'Aurélie',
                    text: 'Non pas coucou',
                    creatorId: aurelie.id),
                Message(
                    name: 'Prof', text: 'Coucou', creatorId: _login.user!.id),
                Message(
                    name: 'Aurélie',
                    text: 'Non pas coucou',
                    creatorId: aurelie.id),
                Message(
                    name: 'Prof', text: 'Coucou', creatorId: _login.user!.id),
                Message(
                    name: 'Aurélie',
                    text: 'Non pas coucou',
                    creatorId: aurelie.id),
              ])));
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _answerQuestions(currentQuestion: 6));
      return;
    }
    if (currentQuestion == 6) {
      _students.setAnswer(
          student: aurelie,
          question: _questions.fromSection(5)[1],
          answer: Answer(isValidated: true));
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _answerQuestions(currentQuestion: 7));
      return;
    }

    _switchToMainLoginPage();
  }

  void _switchToMainLoginPage() {
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    _login = Provider.of<LoginInformation>(context, listen: false);
    _students = Provider.of<AllStudents>(context, listen: false);
    _questions = Provider.of<AllQuestions>(context, listen: false);

    return GestureDetector(
      onTap: _clear,
      child: widget.child,
    );
  }
}

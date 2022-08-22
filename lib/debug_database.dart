import 'package:defi_photo/common/models/discussion.dart';
import 'package:defi_photo/common/widgets/are_you_sure_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './common/models/all_answers.dart';
import './common/models/answer.dart';
import './common/models/company.dart';
import './common/models/enum.dart';
import './common/models/message.dart';
import './common/models/question.dart';
import './common/models/student.dart';
import './common/providers/login_information.dart';
import './common/providers/all_questions.dart';
import './common/providers/all_students.dart';
import './common/widgets/main_drawer.dart' as md;
import '../../screens/login/login_screen.dart';

class DatabaseDebugger extends StatefulWidget {
  const DatabaseDebugger({Key? key}) : super(key: key);

  @override
  State<DatabaseDebugger> createState() => _DatabaseDebuggerState();
}

class _DatabaseDebuggerState extends State<DatabaseDebugger> {
  late LoginInformation _login;
  late AllStudents _students;
  late AllQuestions _questions;

  void _confirm() async {
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
    if (sure != null && sure) {
      _clearAll();
    }
  }

  void _clearAll() {
    _login.userDatabase.deleteUsersInfo();
    _questions.clear(confirm: true);
    _students.clear(confirm: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _addDummyData());
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

  void _answerQuestions() {
    // Wait until student is ready to complete
    _students = Provider.of<AllStudents>(context, listen: false);
    _questions = Provider.of<AllQuestions>(context, listen: false);
    if (_students.length != 2 || _questions.length != 9) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _answerQuestions());
      return;
    }

    final benjamin = _students[0];
    _students.setAnswer(
        student: benjamin,
        question: _questions.fromSection(0)[1],
        answer: Answer(actionRequired: ActionRequired.fromStudent));
    _students.setAnswer(
        student: benjamin,
        question: _questions.fromSection(1)[0],
        answer: Answer(
            discussion: Discussion.fromList(
                [Message(name: benjamin.firstName, text: "Coucou")]),
            actionRequired: ActionRequired.fromTeacher));
    _students.setAnswer(
        student: benjamin,
        question: _questions.fromSection(5)[1],
        answer: Answer(actionRequired: ActionRequired.fromStudent));
    _students.setAnswer(
        student: benjamin,
        question: _questions.fromSection(5)[1],
        answer: Answer(isValidated: true));
    _students.setAnswer(
        student: benjamin,
        question: _questions.fromSection(5)[2],
        answer: Answer(
            discussion: Discussion.fromList(
                [Message(name: benjamin.firstName, text: "Coucou")]),
            actionRequired: ActionRequired.fromTeacher));

    final aurelie = _students[1];
    _students.setAnswer(
        student: aurelie,
        question: _questions.fromSection(5)[2],
        answer: Answer(
            actionRequired: ActionRequired.fromTeacher,
            discussion: Discussion.fromList([
              Message(name: 'Prof', text: 'Coucou'),
              Message(name: 'Aurélie', text: 'Non pas coucou'),
              Message(name: 'Prof', text: 'Coucou'),
              Message(
                  name: 'Aurélie',
                  text:
                      'https://cdn.photographycourse.net/wp-content/uploads/2014/11/'
                      'Landscape-Photography-steps.jpg',
                  isPhotoUrl: true),
              Message(name: 'Prof', text: 'Coucou'),
              Message(name: 'Aurélie', text: 'Non pas coucou'),
              Message(name: 'Prof', text: 'Coucou'),
              Message(name: 'Aurélie', text: 'Non pas coucou'),
              Message(name: 'Prof', text: 'Coucou'),
              Message(name: 'Aurélie', text: 'Non pas coucou'),
              Message(name: 'Prof', text: 'Coucou'),
              Message(
                  name: 'Aurélie',
                  text:
                      'https://cdn.photographycourse.net/wp-content/uploads/2014/11/'
                      'Landscape-Photography-steps.jpg',
                  isPhotoUrl: true),
              Message(name: 'Prof', text: 'Coucou'),
              Message(name: 'Aurélie', text: 'Non pas coucou'),
              Message(name: 'Prof', text: 'Coucou'),
              Message(name: 'Aurélie', text: 'Non pas coucou'),
              Message(name: 'Prof', text: 'Coucou'),
              Message(name: 'Aurélie', text: 'Non pas coucou'),
            ])));
    _students.setAnswer(
        student: aurelie,
        question: _questions.fromSection(5)[1],
        answer: Answer(isValidated: true));

    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    _login = Provider.of<LoginInformation>(context, listen: false);
    _students = Provider.of<AllStudents>(context, listen: false);
    _questions = Provider.of<AllQuestions>(context, listen: false);
    return md.MenuItem(
        title: "Réinitialiser la\nbase de donnée",
        onTap: () => _confirm(),
        iconColor: Colors.red);
  }
}

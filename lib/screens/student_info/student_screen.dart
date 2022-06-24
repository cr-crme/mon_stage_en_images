import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './section_main_page.dart';
import './section_page.dart';
import './widgets/metier_page_navigator.dart';
import './widgets/new_question_alert_dialog.dart';
import '../../common/models/answer.dart';
import '../../common/models/enum.dart';
import '../../common/models/question.dart';
import '../../common/models/student.dart';
import '../../common/providers/all_questions.dart';
import '../../common/providers/students.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({Key? key}) : super(key: key);

  static const routeName = '/student-screen';

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final _pageController = PageController();
  var _currentPage = 0;
  VoidCallback? _newQuestionCallback;

  void onPageChanged(BuildContext context, int page) {
    _currentPage = page;
    _newQuestionCallback = page > 0 ? () => _newQuestion(context) : null;
    setState(() {});
  }

  void onPageChangedRequest(int page) {
    _pageController.animateToPage(page + 1,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void _onBackPressed() {
    if (_currentPage == 0) Navigator.of(context).pop();
    onPageChangedRequest(-1);
  }

  void onStateChange(VoidCallback func) {
    setState(func);
  }

  Future<void> _newQuestion(BuildContext context) async {
    final questions = Provider.of<AllQuestions>(context, listen: false);
    final students = Provider.of<Students>(context, listen: false);
    final currentStudent =
        ModalRoute.of(context)!.settings.arguments as Student;

    final userInput = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) => NewQuestionAlertDialog(
          section: _currentPage - 1, student: currentStudent),
    );
    if (userInput == null) return;

    final question = userInput['question'] as Question;
    final target = userInput['target'] as Target;

    questions.add(question);
    for (var student in students) {
      final isAtive = target == Target.all || student.id == currentStudent.id;
      student.allAnswers
          .add(Answer(isActive: isAtive, question: question, discussion: []));
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final student = ModalRoute.of(context)!.settings.arguments as Student;

    return Consumer<AllQuestions>(builder: (context, questions, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text(student.toString()),
          leading: BackButton(onPressed: _onBackPressed),
          actions: [
            IconButton(
                onPressed: _newQuestionCallback, icon: const Icon(Icons.add))
          ],
        ),
        body: Column(
          children: [
            METIERPageNavigator(
                selected: _currentPage - 1,
                onPageChanged: onPageChangedRequest),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (value) => onPageChanged(context, value),
                children: [
                  SectionMainPage(
                      student: student, onPageChanged: onPageChangedRequest),
                  SectionPage(0,
                      student: student, onStateChange: onStateChange),
                  SectionPage(1,
                      student: student, onStateChange: onStateChange),
                  SectionPage(2,
                      student: student, onStateChange: onStateChange),
                  SectionPage(3,
                      student: student, onStateChange: onStateChange),
                  SectionPage(4,
                      student: student, onStateChange: onStateChange),
                  SectionPage(5,
                      student: student, onStateChange: onStateChange),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './section_main_page.dart';
import './section_page.dart';
import './widgets/metier_page_navigator.dart';
import './widgets/new_question_alert_dialog.dart';
import '../all_students/students_screen.dart';
import '../../common/widgets/main_drawer.dart';
import '../../common/models/question.dart';
import '../../common/models/enum.dart';
import '../../common/models/student.dart';
import '../../common/providers/all_students.dart';
import '../../common/providers/all_questions.dart';
import '../../common/providers/login_information.dart';

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
    if (_currentPage == 0) {
      // Replacement is used to force the redraw of the Notifier.
      // If the redrawing is ever fixed, this can be replaced by a pop.
      Navigator.of(context).pushReplacementNamed(StudentsScreen.routeName);
    }
    onPageChangedRequest(-1);
  }

  void onStateChange(VoidCallback func) {
    setState(func);
  }

  Future<void> _newQuestion(BuildContext context) async {
    final questions = Provider.of<AllQuestions>(context, listen: false);
    final students = Provider.of<AllStudents>(context, listen: false);
    final currentStudent =
        ModalRoute.of(context)!.settings.arguments as Student?;

    final question = await showDialog<Question>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) => NewQuestionAlertDialog(
          section: _currentPage - 1, student: currentStudent),
    );
    if (question == null) return;
    questions.addToAll(question,
        students: students, currentStudent: currentStudent);

    setState(() {});
  }

  AppBar _setAppBar(bool userIsStudent, Student? student) {
    final currentTheme = Theme.of(context).textTheme.titleLarge!;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(student != null ? student.toString() : 'Gestion des questions'),
          if (student != null)
            Text(
              student.company.name,
              style: currentTheme.copyWith(fontSize: 15, color: onPrimaryColor),
            ),
        ],
      ),
      leading: userIsStudent ? null : BackButton(onPressed: _onBackPressed),
      actions: userIsStudent
          ? null
          : [
              IconButton(
                  onPressed: _newQuestionCallback, icon: const Icon(Icons.add))
            ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userIsStudent =
        Provider.of<LoginInformation>(context, listen: false).loginType ==
            LoginType.student;
    var student = ModalRoute.of(context)!.settings.arguments as Student?;

    return Consumer<AllQuestions>(builder: (context, questions, child) {
      return Scaffold(
        appBar: _setAppBar(userIsStudent, student),
        body: Column(
          children: [
            METIERPageNavigator(
              selected: _currentPage - 1,
              onPageChanged: onPageChangedRequest,
              student: student,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (value) => onPageChanged(context, value),
                children: [
                  SectionMainPage(
                      student: student, onPageChanged: onPageChangedRequest),
                  SectionPage(0,
                      studentId: student?.id, onStateChange: onStateChange),
                  SectionPage(1,
                      studentId: student?.id, onStateChange: onStateChange),
                  SectionPage(2,
                      studentId: student?.id, onStateChange: onStateChange),
                  SectionPage(3,
                      studentId: student?.id, onStateChange: onStateChange),
                  SectionPage(4,
                      studentId: student?.id, onStateChange: onStateChange),
                  SectionPage(5,
                      studentId: student?.id, onStateChange: onStateChange),
                ],
              ),
            ),
          ],
        ),
        drawer: userIsStudent ? MainDrawer(student: student) : null,
      );
    });
  }
}

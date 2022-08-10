import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main_metier_page.dart';
import 'question_and_answer_page.dart';
import 'widgets/metier_app_bar.dart';
import '../all_students/students_screen.dart';
import '../../common/widgets/main_drawer.dart';
import '../../common/models/enum.dart';
import '../../common/models/section.dart';
import '../../common/models/student.dart';
import '../../common/providers/all_questions.dart';
import '../../common/providers/login_information.dart';

class QAndAScreen extends StatefulWidget {
  const QAndAScreen({Key? key}) : super(key: key);

  static const routeName = '/q-and-a-screen';

  @override
  State<QAndAScreen> createState() => _QAndAScreenState();
}

class _QAndAScreenState extends State<QAndAScreen> {
  LoginType _loginType = LoginType.none;
  Student? _student;
  QuestionView _questionView = QuestionView.normal;

  final _pageController = PageController();
  var _currentPage = 0;
  VoidCallback? _switchQuestionModeCallback;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _loginType =
        Provider.of<LoginInformation>(context, listen: false).loginType;
    _student = ModalRoute.of(context)!.settings.arguments as Student?;
    _questionView = _loginType == LoginType.teacher && _student == null
        ? QuestionView.modifyForAllStudents
        : QuestionView.normal;
  }

  void onPageChanged(BuildContext context, int page) {
    _currentPage = page;
    _switchQuestionModeCallback = _loginType == LoginType.student ||
            _questionView == QuestionView.modifyForAllStudents ||
            page < 1
        ? null
        : () => _switchToQuestionManagerMode(context);
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

  void _switchToQuestionManagerMode(BuildContext context) {
    if (_loginType == LoginType.student ||
        _questionView == QuestionView.modifyForAllStudents) return;

    _questionView = _questionView == QuestionView.normal
        ? QuestionView.modifyForOneStudent
        : QuestionView.normal;
    setState(() {});
  }

  AppBar _setAppBar(LoginType loginType, Student? student) {
    final currentTheme = Theme.of(context).textTheme.titleLarge!;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(student != null ? student.toString() : 'Gestion des questions'),
          if (loginType == LoginType.student)
            Text(Section.name(_currentPage > 0 ? _currentPage - 1 : 0),
                style:
                    currentTheme.copyWith(fontSize: 15, color: onPrimaryColor)),
          if (loginType == LoginType.teacher && student != null)
            Text(
              student.company.name,
              style: currentTheme.copyWith(fontSize: 15, color: onPrimaryColor),
            ),
        ],
      ),
      leading: loginType == LoginType.student && _currentPage == 0
          ? null
          : BackButton(onPressed: _onBackPressed),
      actions: _switchQuestionModeCallback != null
          ? [
              IconButton(
                  onPressed: _switchQuestionModeCallback,
                  icon: Icon(_questionView != QuestionView.normal
                      ? Icons.save
                      : Icons.edit_rounded))
            ]
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AllQuestions>(builder: (context, questions, child) {
      return Scaffold(
        appBar: _setAppBar(_loginType, _student),
        body: Column(
          children: [
            MetierAppBar(
              selected: _currentPage - 1,
              onPageChanged: onPageChangedRequest,
              student: _student,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (value) => onPageChanged(context, value),
                children: [
                  MainMetierPage(
                      student: _student, onPageChanged: onPageChangedRequest),
                  QuestionAndAnswerPage(
                    0,
                    studentId: _student?.id,
                    onStateChange: onStateChange,
                    questionView: _questionView,
                  ),
                  QuestionAndAnswerPage(
                    1,
                    studentId: _student?.id,
                    onStateChange: onStateChange,
                    questionView: _questionView,
                  ),
                  QuestionAndAnswerPage(
                    2,
                    studentId: _student?.id,
                    onStateChange: onStateChange,
                    questionView: _questionView,
                  ),
                  QuestionAndAnswerPage(
                    3,
                    studentId: _student?.id,
                    onStateChange: onStateChange,
                    questionView: _questionView,
                  ),
                  QuestionAndAnswerPage(
                    4,
                    studentId: _student?.id,
                    onStateChange: onStateChange,
                    questionView: _questionView,
                  ),
                  QuestionAndAnswerPage(
                    5,
                    studentId: _student?.id,
                    onStateChange: onStateChange,
                    questionView: _questionView,
                  ),
                ],
              ),
            ),
          ],
        ),
        drawer: _loginType == LoginType.student
            ? MainDrawer(student: _student)
            : null,
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './section_main_page.dart';
import './section_page.dart';
import './widgets/metier_page_navigator.dart';
import '../../common/models/student.dart';
import '../../common/providers/all_questions.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({Key? key}) : super(key: key);

  static const routeName = '/student-screen';

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final _pageController = PageController();
  var _currentPage = 0;

  void onPageChanged(int page) {
    _currentPage = page;
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

  @override
  Widget build(BuildContext context) {
    final student = ModalRoute.of(context)!.settings.arguments as Student;

    return Consumer<AllQuestions>(builder: (context, questions, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text(student.toString()),
          leading: BackButton(onPressed: _onBackPressed),
        ),
        body: Column(
          children: [
            METIERPageNavigator(
                selected: _currentPage - 1,
                onPageChanged: onPageChangedRequest),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: onPageChanged,
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './section_main_page.dart';
import './section_page.dart';
import './widgets/metier_page_navigator.dart';
import '../../common/models/student.dart';
import '../../common/providers/all_question_lists.dart';

class StudentScreen extends StatelessWidget {
  const StudentScreen({Key? key}) : super(key: key);

  static const routeName = '/student-screen';

  @override
  Widget build(BuildContext context) {
    final student = ModalRoute.of(context)!.settings.arguments as Student;

    return Consumer<AllQuestionList>(
      builder: (context, questions, child) => const _SectionPages(),
    );
  }
}

class _SectionPages extends StatefulWidget {
  const _SectionPages({Key? key}) : super(key: key);

  @override
  State<_SectionPages> createState() => _SectionPagesState();
}

class _SectionPagesState extends State<_SectionPages> {
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

  @override
  Widget build(BuildContext context) {
    final student = ModalRoute.of(context)!.settings.arguments as Student;

    return Scaffold(
      appBar: AppBar(
        title: Text(student.toString()),
        leading: BackButton(onPressed: _onBackPressed),
      ),
      body: Column(
        children: [
          METIERPageNavigator(
              selected: _currentPage - 1, onPageChanged: onPageChangedRequest),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: onPageChanged,
              children: [
                SectionMainPage(
                    student: student, onPageChanged: onPageChangedRequest),
                SectionPage(0, student: student),
                SectionPage(1, student: student),
                SectionPage(2, student: student),
                SectionPage(3, student: student),
                SectionPage(4, student: student),
                SectionPage(5, student: student),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

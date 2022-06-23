import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './section_main_page.dart';
import './section_page.dart';
import '../../common/models/student.dart';
import '../../common/providers/all_question_lists.dart';

class StudentScreen extends StatelessWidget {
  const StudentScreen({Key? key}) : super(key: key);

  static const routeName = '/student-screen';

  @override
  Widget build(BuildContext context) {
    final student = ModalRoute.of(context)!.settings.arguments as Student;

    return Consumer<AllQuestionList>(
      builder: (context, questions, child) => Scaffold(
        body: PageView(children: [
          SectionMainPage(student: student),
          SectionPage(0, student: student),
          SectionPage(1, student: student),
          SectionPage(2, student: student),
          SectionPage(3, student: student),
          SectionPage(4, student: student),
          SectionPage(5, student: student)
        ]),
      ),
    );
  }
}

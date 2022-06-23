import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './widgets/company_tile.dart';
import './widgets/section_tile_in_student.dart';
import '../../common/models/student.dart';
import '../../common/providers/all_question_lists.dart';

class SectionMainPage extends StatelessWidget {
  const SectionMainPage({Key? key, required this.student}) : super(key: key);

  static const routeName = '/section-main-screen';
  final Student student;

  @override
  Widget build(BuildContext context) {
    return Consumer<AllQuestionList>(
      builder: (context, questions, child) => Scaffold(
        appBar: AppBar(
          title: Text(student.toString()),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            CompanyTile(student: student),
            const Divider(),
            SectionTileInStudent(0, student: student),
            const Divider(),
            SectionTileInStudent(1, student: student),
            const Divider(),
            SectionTileInStudent(2, student: student),
            const Divider(),
            SectionTileInStudent(3, student: student),
            const Divider(),
            SectionTileInStudent(4, student: student),
            const Divider(),
            SectionTileInStudent(5, student: student),
            const Divider(),
          ]),
        ),
      ),
    );
  }
}

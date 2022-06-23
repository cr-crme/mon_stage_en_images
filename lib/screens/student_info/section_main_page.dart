import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './widgets/company_tile.dart';
import './widgets/section_tile_in_student.dart';
import '../../common/models/student.dart';
import '../../common/providers/all_questions.dart';

class SectionMainPage extends StatelessWidget {
  const SectionMainPage({
    Key? key,
    required this.student,
    required this.onPageChanged,
  }) : super(key: key);

  static const routeName = '/section-main-screen';
  final Student student;
  final Function(int) onPageChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Consumer<AllQuestions>(
        builder: (context, questions, child) => SingleChildScrollView(
          child: Column(
            children: [
              CompanyTile(student: student),
              const Divider(),
              SectionTileInStudent(0, student: student, onTap: onPageChanged),
              const Divider(),
              SectionTileInStudent(1, student: student, onTap: onPageChanged),
              const Divider(),
              SectionTileInStudent(2, student: student, onTap: onPageChanged),
              const Divider(),
              SectionTileInStudent(3, student: student, onTap: onPageChanged),
              const Divider(),
              SectionTileInStudent(4, student: student, onTap: onPageChanged),
              const Divider(),
              SectionTileInStudent(5, student: student, onTap: onPageChanged),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }
}

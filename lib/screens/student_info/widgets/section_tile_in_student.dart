import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../section_page.dart';
import '../../../common/models/section.dart';
import '../../../common/models/student.dart';
import '../../../common/providers/all_question_lists.dart';

class SectionTileInStudent extends StatelessWidget {
  const SectionTileInStudent(this.sectionIndex,
      {Key? key, required this.student})
      : super(key: key);

  final int sectionIndex;
  final Student student;

  @override
  Widget build(BuildContext context) {
    final questions = Provider.of<AllQuestionList>(context)[sectionIndex];

    return ListTile(
      leading: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(14),
        width: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Section.color(sectionIndex)),
        child: Text(Section.letter(sectionIndex),
            style: const TextStyle(fontSize: 25, color: Colors.white)),
      ),
      title: Text('Questions répondues : 0 / ${questions.number}'),
      trailing: const Icon(Icons.arrow_right),
      onTap: () => Navigator.of(context).pushNamed(SectionPage.routeName,
          arguments: {'student': student, 'sectionIndex': sectionIndex}),
    );
  }
}

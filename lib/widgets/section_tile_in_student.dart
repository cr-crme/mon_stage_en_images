import 'package:flutter/material.dart';

import '../providers/all_question_lists.dart';
import '../screens/section_screen.dart';

class SectionTileInStudent extends StatelessWidget {
  const SectionTileInStudent(this.questions, this.sectionIndex, {Key? key})
      : super(key: key);

  final int sectionIndex;
  final QuestionList questions;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(12),
        width: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: AllQuestionList.color(sectionIndex)),
        child: Text(AllQuestionList.letter(sectionIndex),
            style: const TextStyle(fontSize: 25, color: Colors.white)),
      ),
      title: const Text('Questions répondues : 0 / 1'),
      trailing: const Icon(Icons.arrow_right),
      onTap: () => Navigator.of(context)
          .pushNamed(SectionScreen.routeName, arguments: sectionIndex),
    );
  }
}

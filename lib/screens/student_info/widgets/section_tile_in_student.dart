import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/models/section.dart';
import '../../../common/models/student.dart';
import '../../../common/providers/all_questions.dart';

class SectionTileInStudent extends StatelessWidget {
  const SectionTileInStudent(this.sectionIndex,
      {Key? key, required this.student, required this.onTap})
      : super(key: key);

  final int sectionIndex;
  final Student student;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final questions =
        Provider.of<AllQuestions>(context).fromSection(sectionIndex);
    final answers = student.allAnswers.fromSection(sectionIndex);
    final answered = answers.numberAnswered;
    final number = questions.number;

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
      title: Text('Réponses : $answered / $number',
          style:
              TextStyle(color: answered >= number ? Colors.black : Colors.red)),
      trailing: const Icon(Icons.arrow_right),
      onTap: () => onTap(sectionIndex),
    );
  }
}

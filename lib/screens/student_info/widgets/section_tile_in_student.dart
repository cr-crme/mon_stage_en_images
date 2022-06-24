import 'package:flutter/material.dart';

import '../../../common/models/section.dart';
import '../../../common/models/student.dart';

class SectionTileInStudent extends StatelessWidget {
  const SectionTileInStudent(this.sectionIndex,
      {Key? key, required this.student, required this.onTap})
      : super(key: key);

  final int sectionIndex;
  final Student student;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final answers = student.allAnswers.fromSection(sectionIndex);
    final answered = answers.numberAnswered;
    final active = answers.numberActive;

    return Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: ListTile(
          leading: Container(
            margin: const EdgeInsets.only(bottom: 2),
            width: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Section.color(sectionIndex)),
            child: Text(Section.letter(sectionIndex),
                style: const TextStyle(fontSize: 25, color: Colors.white)),
          ),
          title: Text('Réponses : $answered / $active',
              style: TextStyle(
                  color: active > 0
                      ? (answered >= active ? Colors.black : Colors.red)
                      : Colors.grey)),
          trailing: const Icon(Icons.arrow_right, color: Colors.black),
          onTap: () => onTap(sectionIndex),
        ),
      ),
    );
  }
}

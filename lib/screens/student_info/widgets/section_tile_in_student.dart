import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/models/all_answers.dart';
import '../../../common/models/section.dart';
import '../../../common/models/student.dart';
import '../../../common/widgets/taking_action_notifier.dart';
import '../../../common/providers/all_questions.dart';

class SectionTileInStudent extends StatelessWidget {
  const SectionTileInStudent(this.sectionIndex,
      {Key? key, required this.student, required this.onTap})
      : super(key: key);

  final int sectionIndex;
  final Student? student;
  final Function(int) onTap;

  TextStyle _pickTextStyle(
      int? activeQuestions, int? answeredQuestions, int? needAction) {
    if (activeQuestions == null ||
        answeredQuestions == null ||
        needAction == null) {
      return const TextStyle();
    }

    return TextStyle(
      color: activeQuestions > 0
          ? (answeredQuestions >= activeQuestions ? Colors.black : Colors.red)
          : Colors.grey,
      fontWeight: needAction > 0 ? FontWeight.bold : FontWeight.normal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = Provider.of<AllQuestions>(context, listen: false)
        .fromSection(sectionIndex);

    late final AllAnswers? answers;
    late final int? answered;
    late final int? active;
    late final int? needAction;
    if (student != null) {
      answers = student!.allAnswers.fromQuestions(questions);
      answered = answers.numberAnswered;
      active = answers.numberActive;
      needAction = answers.numberNeedTeacherAction;
    } else {
      answers = null;
      answered = null;
      active = null;
      needAction = null;
    }

    return Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: TakingActionNotifier(
          left: 6,
          top: -9,
          title: needAction.toString(),
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
            title: Text(
              Section.name(sectionIndex),
              style: _pickTextStyle(active, answered, needAction),
            ),
            trailing: answers != null
                ? Text('$answered / $active',
                    style: _pickTextStyle(active, answered, needAction))
                : null,
            onTap: () => onTap(sectionIndex),
          ),
        ),
      ),
    );
  }
}

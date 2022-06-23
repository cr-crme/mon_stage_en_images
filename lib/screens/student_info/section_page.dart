import 'package:flutter/material.dart';

import './widgets/question_and_answer_tile.dart';
import '../../../common/models/student.dart';

class SectionPage extends StatelessWidget {
  const SectionPage(this.sectionIndex,
      {Key? key, required this.student, required this.onStateChange})
      : super(key: key);

  static const routeName = '/section-screen';
  final int sectionIndex;
  final Student student;
  final Function(VoidCallback) onStateChange;

  @override
  Widget build(BuildContext context) {
    final answers = student.allAnswers.fromSection(sectionIndex);
    final activeQuestions = answers.activeQuestions;
    final inactiveQuestions = answers.inactiveQuestions;

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) => Column(
            children: [
              QuestionAndAnswerTile(
                activeQuestions[index],
                answer: student.allAnswers[activeQuestions[index].id],
                onStateChange: onStateChange,
              ),
              const Divider(),
            ],
          ),
          itemCount: activeQuestions.length,
        ),
        ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) => Column(
            children: [
              QuestionAndAnswerTile(
                inactiveQuestions[index],
                answer: student.allAnswers[inactiveQuestions[index].id],
                onStateChange: onStateChange,
              ),
              const Divider(),
            ],
          ),
          itemCount: inactiveQuestions.length,
        ),
      ],
    );
  }
}

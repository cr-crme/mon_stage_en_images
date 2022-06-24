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
    final answeredQuestions = answers.answeredActiveQuestions;
    final unansweredQuestions = answers.unansweredActiveQuestions;
    final inactiveQuestions = answers.inactiveQuestions;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 5, top: 10),
            child: const Text('Questions répondues',
                style: TextStyle(fontSize: 20)),
          ),
          answeredQuestions.isNotEmpty
              ? ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) => QuestionAndAnswerTile(
                    answeredQuestions[index],
                    answer: student.allAnswers[answeredQuestions[index].id],
                    onStateChange: onStateChange,
                    isActive: true,
                  ),
                  itemCount: answeredQuestions.length,
                )
              : Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: const Text(
                    'Aucune question active',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
          Container(
            padding: const EdgeInsets.only(left: 5, top: 45),
            child: const Text('Questions non répondues',
                style: TextStyle(fontSize: 20)),
          ),
          unansweredQuestions.isNotEmpty
              ? ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) => QuestionAndAnswerTile(
                    unansweredQuestions[index],
                    answer: student.allAnswers[unansweredQuestions[index].id],
                    onStateChange: onStateChange,
                    isActive: true,
                  ),
                  itemCount: unansweredQuestions.length,
                )
              : Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: const Text(
                    'Aucune question active',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
          Container(
            padding: const EdgeInsets.only(left: 5, top: 45),
            child: const Text('Questions inactives',
                style: TextStyle(fontSize: 20, color: Colors.grey)),
          ),
          inactiveQuestions.isNotEmpty
              ? ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) => QuestionAndAnswerTile(
                    inactiveQuestions[index],
                    answer: student.allAnswers[inactiveQuestions[index].id],
                    onStateChange: onStateChange,
                    isActive: false,
                  ),
                  itemCount: inactiveQuestions.length,
                )
              : Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: const Text(
                    'Aucune question inactive',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
        ],
      ),
    );
  }
}

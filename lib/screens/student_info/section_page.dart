import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './widgets/question_and_answer_tile.dart';
import '../../common/models/all_answers.dart';
import '../../common/models/student.dart';
import '../../common/providers/all_questions.dart';
import '../../common/providers/all_students.dart';

class SectionPage extends StatelessWidget {
  const SectionPage(this.sectionIndex,
      {Key? key, required this.studentId, required this.onStateChange})
      : super(key: key);

  static const routeName = '/section-screen';
  final int sectionIndex;
  final String? studentId;
  final Function(VoidCallback) onStateChange;

  @override
  Widget build(BuildContext context) {
    final allStudents = Provider.of<AllStudents>(context);
    late Student? student;

    late final AllAnswers? answers;
    late final AllQuestions? answeredQuestions;
    late final AllQuestions? unansweredQuestions;
    late final AllQuestions? inactiveQuestions;
    if (studentId != null) {
      final questions =
          Provider.of<AllQuestions>(context).fromSection(sectionIndex);
      student = allStudents[studentId];
      answers = student.allAnswers.fromQuestions(questions);
      answeredQuestions = answers.answeredActiveQuestions(questions);
      unansweredQuestions = answers.unansweredActiveQuestions(questions);
      inactiveQuestions = answers.inactiveQuestions(questions);
    } else {
      student = null;
      answeredQuestions =
          Provider.of<AllQuestions>(context).fromSection(sectionIndex);
      unansweredQuestions = AllQuestions();
      inactiveQuestions = AllQuestions();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ..._buildQuestionSection(context,
              title: student != null ? 'Questions répondues' : 'Questions',
              titleColor: Colors.black,
              questions: answeredQuestions,
              isActive: true,
              titleIfNone: 'Aucune question active',
              topSpacing: 15),
          if (student != null)
            ..._buildQuestionSection(context,
                title: 'Questions non répondues',
                titleColor: Colors.black,
                questions: unansweredQuestions,
                isActive: true,
                titleIfNone: 'Aucune question active',
                topSpacing: 45),
          if (student != null)
            ..._buildQuestionSection(context,
                title: 'Questions inactives',
                titleColor: Colors.grey,
                questions: inactiveQuestions,
                isActive: false,
                titleIfNone: 'Aucune question inactive',
                topSpacing: 45),
        ],
      ),
    );
  }

  List<Widget> _buildQuestionSection(
    BuildContext context, {
    required String title,
    required Color titleColor,
    required AllQuestions questions,
    required bool isActive,
    required String titleIfNone,
    required double topSpacing,
  }) {
    return [
      Container(
        padding: EdgeInsets.only(left: 5, top: topSpacing),
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: titleColor)),
      ),
      questions.isNotEmpty
          ? ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) => QuestionAndAnswerTile(
                questions[index],
                studentId: studentId,
                onStateChange: onStateChange,
                isActive: isActive,
              ),
              itemCount: questions.length,
            )
          : Container(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                titleIfNone,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
    ];
  }
}

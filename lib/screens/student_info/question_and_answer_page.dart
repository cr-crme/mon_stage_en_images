import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './widgets/question_and_answer_tile.dart';
import '../../common/models/all_answers.dart';
import '../../common/models/enum.dart';
import '../../common/models/section.dart';
import '../../common/models/student.dart';
import '../../common/providers/all_questions.dart';
import '../../common/providers/all_students.dart';
import '../../common/providers/login_information.dart';

class QuestionAndAnswerPage extends StatelessWidget {
  const QuestionAndAnswerPage(this.sectionIndex,
      {Key? key, required this.studentId, required this.onStateChange})
      : super(key: key);

  static const routeName = '/question-and-answer-page';
  final int sectionIndex;
  final String? studentId;
  final Function(VoidCallback) onStateChange;

  @override
  Widget build(BuildContext context) {
    final allStudents = Provider.of<AllStudents>(context, listen: false);
    final userIsStudent =
        Provider.of<LoginInformation>(context, listen: false).loginType ==
            LoginType.student;
    late Student? student;

    late final AllAnswers? answers;
    late final AllQuestions? answeredQuestions;
    late final AllQuestions? unansweredQuestions;
    if (studentId != null) {
      final questions = Provider.of<AllQuestions>(context, listen: false)
          .fromSection(sectionIndex);
      student = allStudents[studentId];
      answers = student.allAnswers.fromQuestions(questions);
      answeredQuestions = answers.answeredQuestions(questions);
      unansweredQuestions = answers.unansweredQuestions(questions);
    } else {
      student = null;
      answeredQuestions = Provider.of<AllQuestions>(context, listen: false)
          .fromSection(sectionIndex);
      unansweredQuestions = AllQuestions();
    }

    final answeredSection = _buildQuestionSection(context,
        title: Section.name(sectionIndex),
        titleColor: Colors.black,
        questions: answeredQuestions,
        titleIfNothing: 'Pas de questions répondues',
        topSpacing: 15);
    final unansweredSection = _buildQuestionSection(context,
        title: '',
        titleColor: Colors.black,
        questions: unansweredQuestions,
        titleIfNothing: '',
        topSpacing: 15);

    final firstSection = userIsStudent ? unansweredSection : answeredSection;
    final secondSection = userIsStudent
        ? answeredSection
        : (student == null ? [] : unansweredSection);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ...firstSection,
          ...secondSection,
        ],
      ),
    );
  }

  List<Widget> _buildQuestionSection(
    BuildContext context, {
    required String? title,
    required Color titleColor,
    required AllQuestions questions,
    required String titleIfNothing,
    required double topSpacing,
  }) {
    return [
      if (title != null)
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
              ),
              itemCount: questions.length,
            )
          : Container(
              padding: const EdgeInsets.only(top: 10),
              child: Text(titleIfNothing),
            ),
    ];
  }
}

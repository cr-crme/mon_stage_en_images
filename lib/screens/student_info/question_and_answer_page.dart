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
      {Key? key,
      required this.studentId,
      required this.onStateChange,
      required this.questionView})
      : super(key: key);

  static const routeName = '/question-and-answer-page';
  final int sectionIndex;
  final String? studentId;
  final Function(VoidCallback) onStateChange;
  final QuestionView questionView;

  @override
  Widget build(BuildContext context) {
    final allStudents = Provider.of<AllStudents>(context, listen: false);
    final loginType =
        Provider.of<LoginInformation>(context, listen: false).loginType;
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
        questions: answeredQuestions,
        titleIfNothing: questionView == QuestionView.normal
            ? 'Aucune question répondue'
            : '');
    final unansweredSection = _buildQuestionSection(context,
        questions: unansweredQuestions, titleIfNothing: '');

    final firstSection =
        loginType == LoginType.student ? unansweredSection : answeredSection;
    final secondSection = loginType == LoginType.student
        ? answeredSection
        : (student == null ? Container() : unansweredSection);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 5, top: 15),
            child: Text(Section.name(sectionIndex),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.black)),
          ),
          if (questionView != QuestionView.normal) const SizedBox(height: 10),
          if (questionView != QuestionView.normal)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                    'Activer pour ${studentId == null ? 'tous' : 'cet élève'}'),
                const SizedBox(width: 25)
              ],
            ),
          firstSection,
          secondSection,
        ],
      ),
    );
  }

  Widget _buildQuestionSection(BuildContext context,
      {required AllQuestions questions, required String titleIfNothing}) {
    return questions.isNotEmpty
        ? ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) => QuestionAndAnswerTile(
              questions[index],
              studentId: studentId,
              onStateChange: onStateChange,
              questionView: questionView,
            ),
            itemCount: questions.length,
          )
        : Container(
            padding: const EdgeInsets.only(top: 10, bottom: 30),
            child: Text(titleIfNothing),
          );
  }
}

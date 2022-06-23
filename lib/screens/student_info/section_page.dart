import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './widgets/metier_page_navigator.dart';
import './widgets/question_and_answer_tile.dart';
import '../../../common/models/section.dart';
import '../../../common/models/student.dart';
import '../../../common/providers/all_question_lists.dart';

class SectionPage extends StatelessWidget {
  const SectionPage(this.sectionIndex, {Key? key, required this.student})
      : super(key: key);

  static const routeName = '/section-screen';
  final int sectionIndex;
  final Student student;

  @override
  Widget build(BuildContext context) {
    final questions =
        Provider.of<AllQuestionList>(context, listen: false)[sectionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Column(
            children: [Text('$student (${Section.letter(sectionIndex)})')]),
      ),
      body: SizedBox(
        child: Column(
          children: [
            const METIERPageNavigator(),
            ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) => Column(
                children: [
                  QuestionAndAnswerTile(
                    questions[index]!,
                    answer: student.allAnswers[questions[index]!.id],
                  ),
                  const Divider(),
                ],
              ),
              itemCount: questions.number,
            ),
          ],
        ),
      ),
    );
  }
}

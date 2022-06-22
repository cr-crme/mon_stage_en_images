import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/question_and_answer_tile.dart';
import '../../../common/models/section.dart';
import '../../../common/models/student.dart';
import '../../../common/providers/all_question_lists.dart';

class SectionScreen extends StatelessWidget {
  const SectionScreen({Key? key}) : super(key: key);

  static const routeName = '/section-screen';

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final sectionIndex = arguments['sectionIndex'] as int;
    final student = arguments['student'] as Student;

    final questions =
        Provider.of<AllQuestionList>(context, listen: false)[sectionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Column(
            children: [Text('$student (${Section.letter(sectionIndex)})')]),
      ),
      body: SizedBox(
        child: ListView.builder(
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
      ),
    );
  }
}

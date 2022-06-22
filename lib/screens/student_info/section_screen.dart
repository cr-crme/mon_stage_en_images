import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './widgets/question_tile.dart';
import '../../../common/models/student.dart';
import '../../../common/providers/all_question_lists.dart';

class SectionScreen extends StatelessWidget {
  const SectionScreen({Key? key}) : super(key: key);

  static const routeName = '/section-screen';

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final index = arguments['sectionIndex'] as int;
    final student = arguments['student'] as Student;

    final questions =
        Provider.of<AllQuestionList>(context, listen: false)[index];
    return Scaffold(
      appBar:
          AppBar(title: Text('$student (${AllQuestionList.letter(index)})')),
      body: ListView.builder(
        itemBuilder: (context, index) => Column(
          children: [
            QuestionTile(questions[index]!),
            const Divider(),
          ],
        ),
        itemCount: questions.number,
      ),
    );
  }
}

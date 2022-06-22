import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/providers/all_question_lists.dart';

class SectionScreen extends StatelessWidget {
  const SectionScreen({Key? key}) : super(key: key);

  static const routeName = '/section-screen';

  @override
  Widget build(BuildContext context) {
    final index = ModalRoute.of(context)!.settings.arguments as int;

    final questions =
        Provider.of<AllQuestionList>(context, listen: false)[index];
    return Scaffold(
      appBar: AppBar(title: Text(AllQuestionList.letter(index))),
      body: Text(questions[0]!.question),
    );
  }
}

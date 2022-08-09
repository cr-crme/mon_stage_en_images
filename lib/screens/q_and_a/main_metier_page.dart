import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/metier_tile.dart';
import '../../common/models/student.dart';
import '../../common/providers/all_questions.dart';

class MainMetierPage extends StatelessWidget {
  const MainMetierPage({
    Key? key,
    required this.student,
    required this.onPageChanged,
  }) : super(key: key);

  static const routeName = '/main-metier-page';
  final Student? student;
  final Function(int) onPageChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Consumer<AllQuestions>(
        builder: (context, questions, child) => SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 15),
              if (student != null)
                Text('Résumé des réponses',
                    style: Theme.of(context).textTheme.titleLarge),
              if (student != null) const SizedBox(height: 5),
              MetierTile(0, student: student, onTap: onPageChanged),
              MetierTile(1, student: student, onTap: onPageChanged),
              MetierTile(2, student: student, onTap: onPageChanged),
              MetierTile(3, student: student, onTap: onPageChanged),
              MetierTile(4, student: student, onTap: onPageChanged),
              MetierTile(5, student: student, onTap: onPageChanged),
            ],
          ),
        ),
      ),
    );
  }
}

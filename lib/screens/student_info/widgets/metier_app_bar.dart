import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/models/student.dart';
import '../../../common/models/section.dart';
import '../../../common/providers/all_questions.dart';
import '../../../common/widgets/taking_action_notifier.dart';

class MetierAppBar extends StatelessWidget {
  const MetierAppBar({
    Key? key,
    required this.selected,
    required this.onPageChanged,
    this.student,
  }) : super(key: key);

  final int selected;
  final Function(int) onPageChanged;
  final Student? student;

  @override
  Widget build(BuildContext context) {
    // There is a bug here, even using listen to true, there is no update of the
    // widget so the takeactionnotifier stays until one changes page.
    // It was worked around by hiding if the page is selected
    final questions = Provider.of<AllQuestions>(context, listen: true);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(90),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _createMetierButton(context, student,
              sectionIndex: 0,
              questions: questions,
              isSelected: selected == 0,
              onPressed: () => onPageChanged(0)),
          _createMetierButton(context, student,
              sectionIndex: 1,
              questions: questions,
              isSelected: selected == 1,
              onPressed: () => onPageChanged(1)),
          _createMetierButton(context, student,
              sectionIndex: 2,
              questions: questions,
              isSelected: selected == 2,
              onPressed: () => onPageChanged(2)),
          _createMetierButton(context, student,
              sectionIndex: 3,
              questions: questions,
              isSelected: selected == 3,
              onPressed: () => onPageChanged(3)),
          _createMetierButton(context, student,
              sectionIndex: 4,
              questions: questions,
              isSelected: selected == 4,
              onPressed: () => onPageChanged(4)),
          _createMetierButton(context, student,
              sectionIndex: 5,
              questions: questions,
              isSelected: selected == 5,
              onPressed: () => onPageChanged(5)),
        ],
      ),
    );
  }

  Widget _createMetierButton(
    BuildContext context,
    Student? student, {
    required questions,
    required sectionIndex,
    required isSelected,
    required onPressed,
  }) {
    final answers =
        student?.allAnswers.fromQuestions(questions.fromSection(sectionIndex));

    return TakingActionNotifier(
      left: 8,
      top: -7,
      number: !isSelected &&
              answers != null &&
              answers.numberOfActionsRequired(context) > 0
          ? 0
          : null,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
            backgroundColor: isSelected
                ? Theme.of(context).colorScheme.primary.withAlpha(100)
                : null),
        child: Text(
          Section.letter(sectionIndex),
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }
}

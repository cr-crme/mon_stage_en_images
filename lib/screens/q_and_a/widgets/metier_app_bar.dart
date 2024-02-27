import 'package:defi_photo/common/models/database.dart';
import 'package:defi_photo/common/models/enum.dart';
import 'package:defi_photo/common/models/section.dart';
import 'package:defi_photo/common/providers/all_answers.dart';
import 'package:defi_photo/common/providers/all_questions.dart';
import 'package:defi_photo/common/widgets/taking_action_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MetierAppBar extends StatelessWidget {
  const MetierAppBar({
    super.key,
    required this.selected,
    required this.onPageChanged,
    this.studentId,
  });

  final int selected;
  final Function(int) onPageChanged;
  final String? studentId;

  @override
  Widget build(BuildContext context) {
    final questions = Provider.of<AllQuestions>(context, listen: false);

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
          _createMetierButton(context,
              sectionIndex: 0,
              questions: questions,
              isSelected: selected == 0,
              onPressed: () => onPageChanged(0)),
          _createMetierButton(context,
              sectionIndex: 1,
              questions: questions,
              isSelected: selected == 1,
              onPressed: () => onPageChanged(1)),
          _createMetierButton(context,
              sectionIndex: 2,
              questions: questions,
              isSelected: selected == 2,
              onPressed: () => onPageChanged(2)),
          _createMetierButton(context,
              sectionIndex: 3,
              questions: questions,
              isSelected: selected == 3,
              onPressed: () => onPageChanged(3)),
          _createMetierButton(context,
              sectionIndex: 4,
              questions: questions,
              isSelected: selected == 4,
              onPressed: () => onPageChanged(4)),
          _createMetierButton(context,
              sectionIndex: 5,
              questions: questions,
              isSelected: selected == 5,
              onPressed: () => onPageChanged(5)),
        ],
      ),
    );
  }

  Widget _createMetierButton(
    BuildContext context, {
    required questions,
    required sectionIndex,
    required isSelected,
    required onPressed,
  }) {
    final answers = Provider.of<AllAnswers>(context, listen: false)
        .fromQuestions(questions.fromSection(sectionIndex), studentId)
        .toList();

    final userType =
        Provider.of<Database>(context, listen: false).currentUser!.userType;

    return TakingActionNotifier(
      left: 8,
      top: -7,
      number: AllAnswers.numberOfActionsRequiredFrom(answers, context) > 0
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
          style: TextStyle(
              fontSize: 16,
              color: userType == UserType.student
                  ? isSelected
                      ? Colors.white
                      : Colors.black
                  : Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }
}

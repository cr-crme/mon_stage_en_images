import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/models/student.dart';
import '../../../common/models/section.dart';
import '../../../common/providers/all_questions.dart';
import '../../../common/widgets/taking_action_notifier.dart';

class METIERPageNavigator extends StatelessWidget {
  const METIERPageNavigator({
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
    // TODO: There is a bug here, even using listen to true, there is no update
    // of the widget so the notifier stays until one changes page. Fix that some
    // day
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
          _createMETIERButton(context, student,
              sectionIndex: 0,
              questions: questions,
              isSelected: selected == 0,
              onPressed: () => onPageChanged(0)),
          _createMETIERButton(context, student,
              sectionIndex: 1,
              questions: questions,
              isSelected: selected == 1,
              onPressed: () => onPageChanged(1)),
          _createMETIERButton(context, student,
              sectionIndex: 2,
              questions: questions,
              isSelected: selected == 2,
              onPressed: () => onPageChanged(2)),
          _createMETIERButton(context, student,
              sectionIndex: 3,
              questions: questions,
              isSelected: selected == 3,
              onPressed: () => onPageChanged(3)),
          _createMETIERButton(context, student,
              sectionIndex: 4,
              questions: questions,
              isSelected: selected == 4,
              onPressed: () => onPageChanged(4)),
          _createMETIERButton(context, student,
              sectionIndex: 5,
              questions: questions,
              isSelected: selected == 5,
              onPressed: () => onPageChanged(5)),
        ],
      ),
    );
  }

  Widget _createMETIERButton(
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
      title:
          answers == null || answers.numberNeedTeacherAction == 0 ? null : "",
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

import 'package:defi_photo/common/models/answer.dart';
import 'package:defi_photo/common/models/database.dart';
import 'package:defi_photo/common/models/enum.dart';
import 'package:defi_photo/common/models/exceptions.dart';
import 'package:defi_photo/common/models/section.dart';
import 'package:defi_photo/common/providers/all_questions.dart';
import 'package:defi_photo/common/providers/all_answers.dart';
import 'package:defi_photo/common/widgets/taking_action_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MetierTile extends StatelessWidget {
  const MetierTile(this.sectionIndex,
      {super.key, required this.studentId, required this.onTap});

  final int sectionIndex;
  final String? studentId;
  final Function(int) onTap;

  TextStyle _pickTextStyle(BuildContext context, int? activeQuestions,
      int? answeredQuestions, int needAction) {
    if (activeQuestions == null || answeredQuestions == null) {
      return const TextStyle(fontSize: 20);
    }

    return TextStyle(
      color: activeQuestions > 0 ? Colors.black : Colors.grey,
      fontWeight: needAction > 0 ? FontWeight.bold : FontWeight.normal,
      fontSize: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    final allAnswers = Provider.of<AllAnswers>(context, listen: false);
    final questions = Provider.of<AllQuestions>(context, listen: false)
        .fromSection(sectionIndex);
    final userType =
        Provider.of<Database>(context, listen: false).currentUser!.userType;

    late final List<Answer>? answers;
    late final int? answered;
    late final int? active;
    if (studentId == null) {
      answers = null;
      answered = null;
      active = null;
    } else {
      answers = allAnswers.filter(
          questionIds: questions.map((e) => e.id),
          studentIds: [studentId!]).toList();
      answered = AllAnswers.numberAnsweredFrom(answers);
      active = AllAnswers.numberActiveFrom(answers);
    }
    final int numberOfActions = answers != null
        ? AllAnswers.numberOfActionsRequiredFrom(answers, context)
        : 0;

    return Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: TakingActionNotifier(
          left: 6,
          top: -5,
          number: userType == UserType.student || numberOfActions == 0
              ? null
              : numberOfActions,
          child: ListTile(
            leading: Container(
              margin: const EdgeInsets.only(bottom: 2),
              width: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Section.color(sectionIndex)),
              child: Text(Section.letter(sectionIndex),
                  style: const TextStyle(fontSize: 25, color: Colors.white)),
            ),
            title: Text(
              Section.name(sectionIndex),
              style: _pickTextStyle(context, active, answered, numberOfActions),
            ),
            trailing: _trailingBuilder(
                context, userType, numberOfActions, answers, answered, active),
            onTap: () => onTap(sectionIndex),
          ),
        ),
      ),
    );
  }

  Widget? _trailingBuilder(BuildContext context, UserType userType,
      int numberOfActions, List<Answer>? answers, int? answered, int? active) {
    if (userType == UserType.student) {
      return numberOfActions > 0
          ? TakingActionNotifier(
              number: numberOfActions,
              borderColor: Colors.black,
            )
          : null;
    } else if (userType == UserType.teacher) {
      return answers != null
          ? Text('$answered / $active',
              style: _pickTextStyle(context, active, answered, numberOfActions))
          : null;
    } else {
      throw const NotLoggedIn();
    }
  }
}

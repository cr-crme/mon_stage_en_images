import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/models/database.dart';
import 'package:mon_stage_en_images/common/models/enum.dart';
import 'package:mon_stage_en_images/common/models/user.dart';
import 'package:mon_stage_en_images/common/providers/all_answers.dart';
import 'package:mon_stage_en_images/common/widgets/taking_action_notifier.dart';
import 'package:mon_stage_en_images/screens/q_and_a/q_and_a_screen.dart';
import 'package:provider/provider.dart';

class StudentListTile extends StatelessWidget {
  const StudentListTile(
    this.studentId, {
    super.key,
    required this.modifyStudentCallback,
  });

  final Function(User) modifyStudentCallback;
  final String studentId;

  @override
  Widget build(BuildContext context) {
    final student = Provider.of<Database>(context, listen: false)
        .students
        .firstWhereOrNull((e) => e.id == studentId);

    final allAnswers = Provider.of<AllAnswers>(context, listen: false)
        .filter(studentIds: [studentId]);
    final numberOfActions =
        AllAnswers.numberNeedTeacherActionFrom(allAnswers, context);

    return Card(
      elevation: 5,
      child: ListTile(
        title: Text(student?.toString() ?? '',
            style: const TextStyle(fontSize: 20)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(student?.companyNames ?? '',
                style: const TextStyle(fontSize: 16)),
            Text(
                'Questions répondues : ${AllAnswers.numberAnsweredFrom(allAnswers)} '
                '/ ${AllAnswers.numberActiveFrom(allAnswers)}',
                style: const TextStyle(fontSize: 16)),
          ],
        ),
        trailing: TakingActionNotifier(
          number: numberOfActions == 0 ? null : numberOfActions,
          padding: 10,
          borderColor: Colors.black,
          child: const Text(""),
        ),
        onTap: () => Navigator.of(context).pushNamed(QAndAScreen.routeName,
            arguments: [Target.individual, PageMode.editableView, student]),
        onLongPress: () {
          if (student == null) return;
          modifyStudentCallback(student);
        },
      ),
    );
  }
}

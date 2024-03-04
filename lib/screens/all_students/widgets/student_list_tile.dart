import 'package:defi_photo/common/models/database.dart';
import 'package:defi_photo/common/models/enum.dart';
import 'package:defi_photo/common/models/user.dart';
import 'package:defi_photo/common/providers/all_answers.dart';
import 'package:defi_photo/common/widgets/taking_action_notifier.dart';
import 'package:defi_photo/screens/q_and_a/q_and_a_screen.dart';
import 'package:flutter/material.dart';
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
        .firstWhere((e) => e.id == studentId);

    final allAnswers = Provider.of<AllAnswers>(context, listen: false)
        .filter(studentIds: [studentId]);
    final numberOfActions =
        AllAnswers.numberNeedTeacherActionFrom(allAnswers, context);

    return Card(
      elevation: 5,
      child: ListTile(
        title: Text(student.toString(), style: const TextStyle(fontSize: 20)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(student.companyNames, style: const TextStyle(fontSize: 16)),
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
        onLongPress: () => modifyStudentCallback(student),
      ),
    );
  }
}

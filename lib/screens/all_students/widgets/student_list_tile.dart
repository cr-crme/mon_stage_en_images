import 'package:defi_photo/common/models/enum.dart';
import 'package:defi_photo/common/models/student.dart';
import 'package:defi_photo/common/providers/all_students.dart';
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

  final Function(Student) modifyStudentCallback;
  final String studentId;

  @override
  Widget build(BuildContext context) {
    final allStudents = Provider.of<AllStudents>(context);
    final student = allStudents.fromId(studentId);

    final numberOfActions = student.allAnswers.numberNeedTeacherAction(context);
    return Card(
      elevation: 5,
      child: ListTile(
        title: Text(student.toString(), style: const TextStyle(fontSize: 20)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(student.company.name, style: const TextStyle(fontSize: 16)),
            Text(
                'Questions répondues : ${student.allAnswers.numberAnswered} '
                '/ ${student.allAnswers.numberActive}',
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

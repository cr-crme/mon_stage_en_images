import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../q_and_a/q_and_a_screen.dart';
import '../../../common/models/student.dart';
import '../../../common/providers/all_students.dart';
import '../../../common/widgets/taking_action_notifier.dart';

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
        title: Text(student.toString()),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(student.company.name),
            Text('Questions répondues : ${student.allAnswers.numberAnswered} '
                '/ ${student.allAnswers.numberActive}'),
          ],
        ),
        trailing: TakingActionNotifier(
          number: numberOfActions == 0 ? null : numberOfActions,
          padding: 10,
          borderColor: Colors.black,
          child: const Text(""),
        ),
        onTap: () => Navigator.of(context)
            .pushNamed(QAndAScreen.routeName, arguments: student),
        onLongPress: () => modifyStudentCallback(student),
      ),
    );
  }
}

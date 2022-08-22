import 'package:flutter/material.dart';

import '../../q_and_a/q_and_a_screen.dart';
import '../../../common/models/student.dart';
import '../../../common/widgets/taking_action_notifier.dart';

class StudentListTile extends StatelessWidget {
  const StudentListTile(
    this.student, {
    Key? key,
    required this.removeItemCallback,
    required this.modifyStudentCallback,
  }) : super(key: key);

  final Function(Student) modifyStudentCallback;
  final Function(Student) removeItemCallback;
  final Student student;

  @override
  Widget build(BuildContext context) {
    // There is a bug here as the main page Notifier does not update
    // For now, it was worked around by forcing the redraw of the page from
    // PushReplacement instead of poping back the page
    final numberOfActions = student.allAnswers.numberNeedTeacherAction(context);
    return TakingActionNotifier(
      number: numberOfActions == 0 ? null : numberOfActions,
      top: -6,
      left: 2,
      borderColor: Colors.black,
      child: Card(
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
          trailing: IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () => removeItemCallback(student),
          ),
          onTap: () => Navigator.of(context)
              .pushNamed(QAndAScreen.routeName, arguments: student),
          onLongPress: () => modifyStudentCallback(student),
        ),
      ),
    );
  }
}

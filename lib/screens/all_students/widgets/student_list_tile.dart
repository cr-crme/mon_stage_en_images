import 'package:flutter/material.dart';

import '../../student_info/student_screen.dart';
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
    final numberOfActions = student.allAnswers.numberNeedTeacherAction;
    return TakingActionNotifier(
      number: numberOfActions == 0 ? null : numberOfActions,
      top: -6,
      left: 2,
      borderColor: Colors.black,
      child: Card(
        elevation: 5,
        child: ListTile(
          title: Text(student.toString()),
          subtitle:
              Text('Questions répondues : ${student.allAnswers.numberAnswered} '
                  '/ ${student.allAnswers.numberActive}'),
          trailing: IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () => removeItemCallback(student),
          ),
          onTap: () => Navigator.of(context)
              .pushNamed(StudentScreen.routeName, arguments: student),
          onLongPress: () => modifyStudentCallback(student),
        ),
      ),
    );
  }
}

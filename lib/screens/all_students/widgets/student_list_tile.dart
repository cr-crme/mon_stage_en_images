import 'package:flutter/material.dart';

import '../../student_info/student_screen.dart';
import '../../../common/models/student.dart';

class StudentListTile extends StatelessWidget {
  const StudentListTile(this.student,
      {Key? key, required this.removeItemCallback})
      : super(key: key);

  final Function(Student) removeItemCallback;
  final Student student;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: ListTile(
        title: Text(student.toString()),
        subtitle: Text(
            'Questions répondues : ${student.allAnswers.numberAnswered} / ${student.allAnswers.numberActive}'),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onPressed: () => removeItemCallback(student),
        ),
        onTap: () => Navigator.of(context)
            .pushNamed(StudentScreen.routeName, arguments: student),
      ),
    );
  }
}

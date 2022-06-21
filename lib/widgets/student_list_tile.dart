import 'package:flutter/material.dart';

import '../models/student.dart';
import '../screens/student_main_screen.dart';

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
        subtitle: Text('Progression : ${student.progression}%'),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onPressed: () => removeItemCallback(student),
        ),
        onTap: () => Navigator.of(context)
            .pushNamed(StudentMainScreen.routeName, arguments: student),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/student.dart';
import '../screens/student_main_screen.dart';

class StudentListTile extends StatelessWidget {
  const StudentListTile(this.student, {Key? key}) : super(key: key);

  final Student student;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: ListTile(
        title: Text(student.toString()),
        subtitle: Text('Progression : ${student.progression}%'),
        onTap: () => Navigator.of(context)
            .pushNamed(StudentMainScreen.routeName, arguments: student),
      ),
    );
  }
}

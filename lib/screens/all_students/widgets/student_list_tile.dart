import 'package:flutter/material.dart';

import '../../../common/models/student.dart';
import '../../student_info/student_main_screen.dart';

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
        subtitle: const Text('Progression : 0%'),
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

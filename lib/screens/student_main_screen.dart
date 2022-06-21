import 'package:flutter/material.dart';

import '../models/student.dart';

class StudentMainScreen extends StatelessWidget {
  const StudentMainScreen({Key? key}) : super(key: key);

  static const routeName = '/student-main-screen';

  @override
  Widget build(BuildContext context) {
    final student = ModalRoute.of(context)!.settings.arguments as Student;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(student.toString()),
      ),
      body: Center(
        child: Text('Progression : ${student.progression}%'),
      ),
    );
  }
}

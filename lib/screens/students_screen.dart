import 'package:defi_photo/screens/new_student_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/students.dart';
import '../models/student.dart';
import '../widgets/student_list_tile.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({Key? key}) : super(key: key);

  static const routeName = '/student-screen';

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  Future<void> _showNewStudent() async {
    final students = Provider.of<Students>(context, listen: false);

    final student = await showDialog<Student>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return const NewStudentScreen();
      },
    );
    if (student == null) return;

    students.add(student);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Élèves'),
      ),
      body: Consumer<Students>(
        builder: (context, students, child) => ListView.builder(
          itemBuilder: (context, index) => StudentListTile(students[index]!),
          itemCount: students.count,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewStudent,
        child: const Icon(Icons.add),
      ),
    );
  }
}

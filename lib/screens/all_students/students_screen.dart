import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './widgets/new_student_alert_dialog.dart';
import './widgets/student_list_tile.dart';
import '../../common/providers/all_questions.dart';
import '../../common/providers/all_students.dart';
import '../../common/models/answer.dart';
import '../../common/models/enum.dart';
import '../../common/widgets/main_drawer.dart';
import '../../common/models/student.dart';
import '../../common/widgets/are_you_sure_dialog.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({Key? key}) : super(key: key);

  static const routeName = '/students-screen';

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  Future<void> _showNewStudent() async {
    final students = Provider.of<AllStudents>(context, listen: false);
    final questions = Provider.of<AllQuestions>(context, listen: false);

    final student = await showDialog<Student>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return const NewStudentAlertDialog();
      },
    );
    if (student == null) return;

    for (final question in questions) {
      student.allAnswers[question] = Answer(
          isActive: question.defaultTarget == Target.all,
          actionRequired: ActionRequired.fromStudent);
    }
    students.add(student);
  }

  Future<void> _modifyStudent(Student student) async {
    final students = Provider.of<AllStudents>(context, listen: false);

    final newInfo = await showDialog<Student>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return NewStudentAlertDialog(student: student);
      },
    );
    if (newInfo == null) return;

    students.replace(
      student.copyWith(
        firstName: newInfo.firstName,
        lastName: newInfo.lastName,
        company: student.company.copyWith(name: newInfo.company.name),
      ),
    );
  }

  Future<void> _removeStudent(Student student) async {
    final students = Provider.of<AllStudents>(context, listen: false);

    final sure = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AreYouSureDialog(
          title: 'Suppression des données d\'un étudiant',
          content:
              'Êtes-vous certain(e) de vouloir supprimer les données de $student?',
        );
      },
    );

    if (sure!) {
      students.remove(student.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Élèves'),
        actions: [
          IconButton(onPressed: _showNewStudent, icon: const Icon(Icons.add)),
        ],
      ),
      body: Consumer<AllStudents>(
        builder: (context, students, child) => Column(
          children: [
            const SizedBox(height: 15),
            Text('Défi Photos', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 3),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) => StudentListTile(
                  students[index],
                  removeItemCallback: _removeStudent,
                  modifyStudentCallback: _modifyStudent,
                ),
                itemCount: students.count,
              ),
            ),
          ],
        ),
      ),
      drawer: const MainDrawer(),
    );
  }
}

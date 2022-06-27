import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './widgets/new_student_alert_dialog.dart';
import './widgets/student_list_tile.dart';
import '../login/login_screen.dart';
import '../student_info/student_screen.dart';
import '../../common/providers/all_questions.dart';
import '../../common/providers/all_students.dart';
import '../../common/models/answer.dart';
import '../../common/models/enum.dart';
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
          isActive: question.defaultTarget == Target.all, discussion: []);
    }
    students.add(student);
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
        title: const Text('Gestion des stages'),
      ),
      body: Consumer<AllStudents>(
        builder: (context, students, child) => Column(
          children: [
            const SizedBox(height: 15),
            Text('Élèves enregistrés',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 3),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) => StudentListTile(
                  students[index],
                  removeItemCallback: _removeStudent,
                ),
                itemCount: students.count,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewStudent,
        child: const Icon(Icons.add),
      ),
      drawer: Drawer(
          child: Scaffold(
        appBar:
            AppBar(title: const Text('Menu principal'), leading: Container()),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MenuItem(
                title: 'Élèves',
                onTap: () =>
                    Navigator.of(context).pushNamed(StudentsScreen.routeName)),
            MenuItem(
                title: 'Gestion des questions',
                onTap: () =>
                    Navigator.of(context).pushNamed(StudentScreen.routeName)),
            MenuItem(
                title: 'Déconnexion',
                onTap: () => Navigator.of(context)
                    .pushReplacementNamed(LoginScreen.routeName)),
          ],
        ),
      )),
    );
  }
}

class MenuItem extends StatelessWidget {
  const MenuItem(
      {Key? key, required this.title, required this.onTap, this.iconColor})
      : super(key: key);

  final String title;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Icon(
          Icons.cottage,
          color: iconColor ?? Theme.of(context).colorScheme.secondary,
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        onTap: onTap,
      ),
    );
  }
}

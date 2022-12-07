import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/answer.dart';
import '/common/models/enum.dart';
import '/common/models/student.dart';
import '/common/models/user.dart';
import '/common/providers/all_questions.dart';
import '/common/providers/all_students.dart';
import '/common/providers/login_information.dart';
import '/common/widgets/are_you_sure_dialog.dart';
import '/common/widgets/database_clearer.dart';
import '/common/widgets/main_drawer.dart';
import 'widgets/new_student_alert_dialog.dart';
import 'widgets/student_list_tile.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({
    super.key,
    required this.databaseClearerOptions,
  });

  static const routeName = '/students-screen';
  final DatabaseClearerOptions databaseClearerOptions;

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

void _showSnackbar(String message, ScaffoldMessengerState scaffold) {
  scaffold.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ),
  );
}

class _StudentsScreenState extends State<StudentsScreen> {
  Future<void> _showNewStudent() async {
    final scaffold = ScaffoldMessenger.of(context);
    final loginInformation =
        Provider.of<LoginInformation>(context, listen: false);
    final students = Provider.of<AllStudents>(context, listen: false);
    final questions = Provider.of<AllQuestions>(context, listen: false);

    final student = await showDialog<Student>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return const NewStudentAlertDialog();
      },
    );
    if (student == null) {
      _showSnackbar('Ajout de l\'étudiant(e) annulé', scaffold);
      return;
    }

    final status = await loginInformation.addUserToDatabase(
      newUser: User(
        firstName: student.firstName,
        lastName: student.lastName,
        email: student.email,
        addedBy: loginInformation.user!.id,
        isStudent: true,
        shouldChangePassword: true,
        studentId: student.id,
      ),
      password: 'defiPhoto',
    );
    if (status != LoginStatus.success) {
      final message = status == LoginStatus.couldNotCreateUser
          ? 'Échec de l\'ajout de l\'étudiant(e). Il n\'est pas possible '
              'd\'ajouter deux étudiant(e) avec la même adresse.'
          : 'Erreur inconnue lors de l\'ajout de l\'étudiant(e)';

      _showSnackbar(message, scaffold);
      return;
    }

    for (final question in questions) {
      student.allAnswers[question] = Answer(
          isActive: question.defaultTarget == Target.all,
          actionRequired: ActionRequired.fromStudent);
    }
    students.add(student);
  }

  Future<void> _modifyStudent(Student student) async {
    final scaffold = ScaffoldMessenger.of(context);
    final loginInformation =
        Provider.of<LoginInformation>(context, listen: false);
    final students = Provider.of<AllStudents>(context, listen: false);

    final newInfo = await showDialog<Student>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return NewStudentAlertDialog(
          student: student,
          deleteCallback: _removeStudent,
        );
      },
    );
    if (newInfo == null) return;

    final user = await loginInformation.getUserFromDatabase(student.email);
    if (user == null) {
      _showSnackbar('Étudiant(e) n\'a pas été trouvé(e) dans la base de donnée',
          scaffold);
      return;
    }
    final status = await loginInformation.modifyUserFromDatabase(user.copyWith(
        firstName: newInfo.firstName, lastName: newInfo.lastName, id: user.id));
    if (status != LoginStatus.success) {
      _showSnackbar('Échec de la modification de l\'étudiant', scaffold);
      return;
    }

    students.replace(
      student.copyWith(
        firstName: newInfo.firstName,
        lastName: newInfo.lastName,
        company: student.company.copyWith(name: newInfo.company.name),
      ),
    );
  }

  Future<void> _removeStudent(Student student) async {
    final scaffold = ScaffoldMessenger.of(context);
    final loginInformation =
        Provider.of<LoginInformation>(context, listen: false);
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

    if (!sure!) {
      _showSnackbar('Suppression de l\'étudiant annulée', scaffold);
      return;
    }

    var status = await loginInformation.deleteUserFromDatabase(student.email);
    if (status != LoginStatus.success) {
      _showSnackbar(
          'La supression d\'étudiant n\'est pas encore disponible.', scaffold);
      return;
    }

    students.remove(student.id);
  }

  @override
  Widget build(BuildContext context) {
    final students =
        Provider.of<AllStudents>(context).toListByTime(reversed: true);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Élèves'),
        actions: [
          IconButton(onPressed: _showNewStudent, icon: const Icon(Icons.add)),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 15),
          Text('Défi Photos', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 3),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) => StudentListTile(
                students[index].id,
                modifyStudentCallback: _modifyStudent,
              ),
              itemCount: students.length,
            ),
          ),
        ],
      ),
      drawer: MainDrawer(databaseClearerOptions: widget.databaseClearerOptions),
    );
  }
}

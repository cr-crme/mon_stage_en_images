import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/answer.dart';
import '/common/models/database.dart';
import '/common/models/enum.dart';
import '/common/models/student.dart';
import '/common/models/user.dart';
import '/common/providers/all_questions.dart';
import '/common/providers/all_students.dart';
import '/common/widgets/are_you_sure_dialog.dart';
import '/common/widgets/main_drawer.dart';
import 'widgets/new_student_alert_dialog.dart';
import 'widgets/student_list_tile.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({
    super.key,
  });

  static const routeName = '/students-screen';

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
    final database = Provider.of<Database>(context, listen: false);
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

    final status = await database.addUser(
      newUser: User(
        firstName: student.firstName,
        lastName: student.lastName,
        email: student.email,
        addedBy: database.currentUser!.id,
        userType: UserType.student,
        shouldChangePassword: true,
        studentId: student.id,
      ),
      password: 'defiPhoto',
    );
    if (status != EzloginStatus.success) {
      final message = status == EzloginStatus.couldNotCreateUser
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
    final database = Provider.of<Database>(context, listen: false);
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

    final user = await database.user(student.email);
    if (user == null) {
      _showSnackbar('Étudiant(e) n\'a pas été trouvé(e) dans la base de donnée',
          scaffold);
      return;
    }
    final status = await database.modifyUser(
        user: user,
        newInfo: user.copyWith(
            firstName: newInfo.firstName,
            lastName: newInfo.lastName,
            id: user.id));
    if (status != EzloginStatus.success) {
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
    final database = Provider.of<Database>(context, listen: false);
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

    final studentUser = await database.user(student.email);
    if (studentUser == null) return;
    var status = await database.deleteUser(user: studentUser);
    if (status != EzloginStatus.success) {
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
    students.sort(
        (a, b) => a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase()));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes élèves'),
        actions: [
          IconButton(
            onPressed: _showNewStudent,
            icon: const Icon(
              Icons.add,
            ),
            iconSize: 35,
            color: Colors.black,
          ),
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
      drawer: const MainDrawer(),
    );
  }
}

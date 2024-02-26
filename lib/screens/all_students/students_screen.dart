import 'package:defi_photo/common/models/answer.dart';
import 'package:defi_photo/common/models/database.dart';
import 'package:defi_photo/common/models/enum.dart';
import 'package:defi_photo/common/models/student.dart';
import 'package:defi_photo/common/models/user.dart';
import 'package:defi_photo/common/providers/all_questions.dart';
import 'package:defi_photo/common/providers/all_students.dart';
import 'package:defi_photo/common/widgets/are_you_sure_dialog.dart';
import 'package:defi_photo/common/widgets/main_drawer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:provider/provider.dart';

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

void _showSnackbar(Widget content, ScaffoldMessengerState scaffold) {
  scaffold.showSnackBar(
    SnackBar(
        content: content,
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'Fermer',
          textColor: Colors.white,
          onPressed: scaffold.hideCurrentSnackBar,
        )),
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
      _showSnackbar(const Text('Ajout de l\'étudiant(e) annulé'), scaffold);
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
      final content = status == EzloginStatus.couldNotCreateUser
          ? Text.rich(TextSpan(
              children: [
                const TextSpan(
                    text:
                        'Échec de l\'ajout de l\'étudiant(e). Il n\'est pas possible '
                        'd\'ajouter deux étudiant(e) avec la même adresse.\n\n'
                        'Si vous souhaitez demander les droits pour cet élève, veuillez '),
                TextSpan(
                  text: 'cliquer ici',
                  style: const TextStyle(
                      color: Colors.blue, decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _requestStudent(student),
                ),
                const TextSpan(
                  text: '.',
                ),
              ],
            ))
          : const Text('Erreur inconnue lors de l\'ajout de l\'étudiant(e)');

      _showSnackbar(content, scaffold);
      return;
    }

    for (final question in questions) {
      student.allAnswers[question] = Answer(
          isActive: question.defaultTarget == Target.all,
          actionRequired: ActionRequired.fromStudent);
    }
    students.add(student);
  }

  Future<void> _requestStudent(Student studentLocal) async {
    final database = Provider.of<Database>(context, listen: false);
    final student = await database.user(studentLocal.email);

    final email = Email(
        recipients: ['pariterre@hotmail.com'],
        subject: 'Prise en charge d\'un élève',
        body:
            'Bonjour,\n\nJe suis un\u00b7e utilisateur\u00b7trice de l\'application '
            'Défi Photos et je souhaiterais faire la demande de la '
            'prise en charge d\'un élève.\n\n'
            '\tMon courriel : ${database.currentUser!.email}\n'
            '\tCourriel de l\'élève : ${student!.email}\n'
            '\tNuméro d\'identification : ${student.studentId}.\n\n'
            'Merci de votre aide.');
    await FlutterEmailSender.send(email);
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
      _showSnackbar(
          const Text(
              'Étudiant(e) n\'a pas été trouvé(e) dans la base de donnée'),
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
      _showSnackbar(
          const Text('Échec de la modification de l\'étudiant'), scaffold);
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
      _showSnackbar(const Text('Suppression de l\'étudiant annulée'), scaffold);
      return;
    }

    final studentUser = await database.user(student.email);
    if (studentUser == null) return;
    var status = await database.deleteUser(user: studentUser);
    if (status != EzloginStatus.success) {
      _showSnackbar(
          const Text('La supression d\'étudiant n\'est pas encore disponible.'),
          scaffold);
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
          const SizedBox(width: 15),
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

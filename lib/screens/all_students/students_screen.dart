import 'package:defi_photo/common/models/database.dart';
import 'package:defi_photo/common/models/user.dart';
import 'package:defi_photo/common/providers/all_questions.dart';
import 'package:defi_photo/common/providers/all_answers.dart';
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
  Future<void> _addStudent() async {
    final scaffold = ScaffoldMessenger.of(context);
    final database = Provider.of<Database>(context, listen: false);
    final questions = Provider.of<AllQuestions>(context, listen: false);
    final answers = Provider.of<AllAnswers>(context, listen: false);

    final student = await showDialog<User>(
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

    final status = await database.addStudent(
        newStudent: student, questions: questions, answers: answers);
    if (!mounted) return;

    switch (status) {
      case EzloginStatus.success:
        return;
      case EzloginStatus.alreadyCreated:
      case EzloginStatus.wrongInfoWhileCreating:
        _showSnackbar(
            Text.rich(TextSpan(
              children: [
                const TextSpan(
                    text: 'Il n\'est pas possible d\'ajouter deux étudiant(e) '
                        'avec la même adresse courriel.\n\n'
                        'Si vous souhaitez demander les droits pour cet élève, '
                        'veuillez '),
                TextSpan(
                  text: 'cliquer ici',
                  style: const TextStyle(
                      color: Colors.blue, decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _requestStudent(student.email),
                ),
                const TextSpan(
                  text: '.',
                ),
              ],
            )),
            scaffold);
        return;
      default:
        _showSnackbar(
            const Text('Erreur inconnue lors de l\'ajout de l\'élève'),
            scaffold);
        return;
    }
  }

  Future<void> _modifyStudent(User student) async {
    final database = Provider.of<Database>(context, listen: false);
    final scaffold = ScaffoldMessenger.of(context);

    final newInfo = await showDialog<User>(
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

    final status = await database.modifyStudent(newInfo: newInfo);
    switch (status) {
      case EzloginStatus.success:
        return;
      case EzloginStatus.userNotFound:
        _showSnackbar(
            const Text(
                'Étudiant(e) n\'a pas été trouvé(e) dans la base de donnée'),
            scaffold);
        return;
      default:
        _showSnackbar(
            const Text(
                'Erreur inconnue lors de la modification de l\'étudiant'),
            scaffold);
        return;
    }
  }

  Future<void> _requestStudent(String studentEmail) async {
    final database = Provider.of<Database>(context, listen: false);
    final student = await database.userFromEmail(studentEmail);
    if (student == null) return;

    final email = Email(
        recipients: ['pariterre@hotmail.com'],
        subject: 'Prise en charge d\'un élève',
        body:
            'Bonjour,\n\nJe suis un\u00b7e utilisateur\u00b7trice de l\'application '
            'Défi Photos et je souhaiterais faire la demande de la '
            'prise en charge d\'un élève. Vous trouverez les données importantes '
            'ci-bas :\n\n'
            'Mes informations :\n'
            '    Courriel : ${database.currentUser!.email}\n'
            '    Identifiant : ${database.currentUser!.id}\n'
            'Informations de l\'élève :\n'
            '    Courriel : ${student.email}\n'
            '    Identifiant : ${student.id}\n'
            '    Indentifiant du superviseur actuel : ${student.supervisedBy}\n'
            '    Nom de la nouvelle compagnie de stage : ${student.companyNames}\n\n'
            'Merci de votre aide.');
    await FlutterEmailSender.send(email);
  }

  Future<void> _removeStudent(User student) async {
    final scaffold = ScaffoldMessenger.of(context);
    final database = Provider.of<Database>(context, listen: false);

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
  }

  @override
  Widget build(BuildContext context) {
    final students = Provider.of<Database>(context).students.toList();
    students.sort(
        (a, b) => a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes élèves'),
        actions: [
          IconButton(
            onPressed: _addStudent,
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

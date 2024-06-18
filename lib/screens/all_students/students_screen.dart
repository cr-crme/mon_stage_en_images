import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:mon_stage_en_images/common/helpers/helpers.dart';
import 'package:mon_stage_en_images/common/models/database.dart';
import 'package:mon_stage_en_images/common/models/themes.dart';
import 'package:mon_stage_en_images/common/models/user.dart';
import 'package:mon_stage_en_images/common/providers/all_answers.dart';
import 'package:mon_stage_en_images/common/providers/all_questions.dart';
import 'package:mon_stage_en_images/common/widgets/are_you_sure_dialog.dart';
import 'package:mon_stage_en_images/common/widgets/main_drawer.dart';
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

    Future<void> needAuthenticationFailed() async {
      _showSnackbar(
          Text.rich(TextSpan(
            children: [
              const TextSpan(
                  text:
                      'Vous devez confirmer votre identité pour pouvoir ajouter '
                      'un élève. Svp, déconnectez-vous et reconnectez-vous en '),
              TextSpan(
                text: 'cliquant ici',
                style: const TextStyle(
                    color: Colors.blue, decoration: TextDecoration.underline),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    if (!mounted) return;
                    scaffold.hideCurrentSnackBar;
                    Helpers.onClickQuit(context);
                  },
              ),
            ],
          )),
          scaffold);
    }

    final database = Provider.of<Database>(context, listen: false);
    final questions = Provider.of<AllQuestions>(context, listen: false);
    final answers = Provider.of<AllAnswers>(context, listen: false);

    if (database.fromAutomaticLogin) {
      await needAuthenticationFailed();
      return;
    }

    final student = await showDialog<User>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return const NewStudentAlertDialog();
      },
    );
    if (student == null) {
      _showSnackbar(const Text('Ajout de l\'élève annulé'), scaffold);
      return;
    }

    final status = await database.addStudent(
        newStudent: student, questions: questions, answers: answers);
    if (!mounted) return;

    switch (status) {
      case EzloginStatus.success:
        await showDialog(
            barrierDismissible: false,
            context: context,
            builder: ((context) => AlertDialog(
                  title: const Text('Élève ajouté'),
                  content: Text.rich(TextSpan(
                    children: [
                      const TextSpan(
                          text: 'L\'élève a été ajouté(e) avec succès.'),
                      const TextSpan(
                          text: 'Vous pouvez maintenant demander à l\'élève de '
                              'télécharger l\'application '),
                      const TextSpan(
                          text: 'Mon stage en images',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(
                          text: ' et de s\'authentifier avec '
                              'les informations suivantes:\n'
                              '    Courriel: '),
                      TextSpan(
                          text: student.email,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: '\n    Mot de passe: '),
                      const TextSpan(
                          text: Database.defaultStudentPassword,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  )),
                  actions: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: studentTheme().outlinedButtonTheme.style,
                      child: const Text('Fermer'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final email = Email(
                            recipients: [student.email],
                            subject: 'Mon stage en images',
                            body:
                                'Bonjour,\n\nJe suis ton enseignant(e)! Je t\'ai inscrit(e) à '
                                '« Mon stage en images ». Une fois l\'application téléchargée, tu '
                                'pourras t\'y connecter avec ces informations:\n\n'
                                'Courriel : ${student.email}\n'
                                'Mot de passe: ${Database.defaultStudentPassword}\n\n'
                                'Bonne journée!');
                        await FlutterEmailSender.send(email);
                      },
                      style: studentTheme().elevatedButtonTheme.style,
                      child: const Text('Envoyer courriel'),
                    ),
                  ],
                )));
        return;
      case EzloginStatus.needAuthentication:
        await needAuthenticationFailed();
        return;
      case EzloginStatus.alreadyCreated:
      case EzloginStatus.wrongInfoWhileCreating:
        _showSnackbar(
            Text.rich(TextSpan(
              children: [
                const TextSpan(
                    text: 'Il n\'est pas possible d\'ajouter deux élèves '
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
                'L\'élève n\'a pas été trouvé(e) dans la base de donnée'),
            scaffold);
        return;
      default:
        _showSnackbar(
            const Text('Erreur inconnue lors de la modification de l\'élève'),
            scaffold);
        return;
    }
  }

  Future<void> _requestStudent(String studentEmail) async {
    final database = Provider.of<Database>(context, listen: false);
    final student = await database.userFromEmail(studentEmail);
    if (student == null) return;

    final email = Email(
        recipients: ['recherchetic@gmail.com'],
        subject: 'Mon stage en images - Prise en charge d\'un élève',
        body: 'Bonjour,\n\nJe suis un(e) utilisateur(trice) de l\'application '
            '« Mon stage en images » et je souhaiterais faire la demande de la '
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
          title: 'Suppression des données d\'un élève',
          content:
              'Êtes-vous certain(e) de vouloir supprimer les données de $student?',
        );
      },
    );

    if (!sure!) {
      _showSnackbar(const Text('Suppression de l\'élève annulée'), scaffold);
      return;
    }

    final studentUser = await database.user(student.email);
    if (studentUser == null) return;
    var status = await database.deleteUser(user: studentUser);
    if (status != EzloginStatus.success) {
      _showSnackbar(
          const Text('La supression d\'élève n\'est pas encore disponible.'),
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
          Text('Mon stage en images',
              style: Theme.of(context).textTheme.titleLarge),
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

import 'package:defi_photo/common/models/database.dart';
import 'package:defi_photo/common/models/enum.dart';
import 'package:defi_photo/common/widgets/are_you_sure_dialog.dart';
import 'package:defi_photo/screens/all_students/students_screen.dart';
import 'package:defi_photo/screens/login/login_screen.dart';
import 'package:defi_photo/screens/q_and_a/q_and_a_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  void _onClickQuit(BuildContext context) async {
    final navigator = Navigator.of(context);
    final sure = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AreYouSureDialog(
          title: 'Déconnexion',
          content: 'Êtes-vous certain(e) de vouloir vous déconnecter?',
        );
      },
    );

    if (!sure!) {
      return;
    }

    if (!context.mounted) return;
    final database = Provider.of<Database>(context, listen: false);
    await database.logout();
    navigator.pushReplacementNamed(LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final userType =
        Provider.of<Database>(context, listen: false).currentUser!.userType;

    return Drawer(
      child: Scaffold(
        appBar:
            AppBar(title: const Text('Menu principal'), leading: Container()),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userType == UserType.teacher)
              MenuItem(
                  title: 'Mes élèves',
                  icon: Icons.person,
                  onTap: () => Navigator.of(context)
                      .pushNamed(StudentsScreen.routeName)),
            if (userType == UserType.teacher)
              MenuItem(
                title: 'Résumé des réponses',
                icon: Icons.question_answer,
                onTap: () => Navigator.of(context).pushReplacementNamed(
                    QAndAScreen.routeName,
                    arguments: [Target.all, PageMode.fixView, null]),
              ),
            if (userType == UserType.teacher) const Divider(),
            if (userType == UserType.teacher)
              MenuItem(
                  title: 'Gestion des questions',
                  icon: Icons.speaker_notes,
                  onTap: () => Navigator.of(context).pushReplacementNamed(
                      QAndAScreen.routeName,
                      arguments: [Target.all, PageMode.edit, null])),
            if (userType == UserType.teacher) const Divider(),
            MenuItem(
                title: 'Déconnexion',
                icon: Icons.exit_to_app,
                onTap: () => _onClickQuit(context)),
          ],
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  const MenuItem(
      {super.key,
      required this.title,
      required this.icon,
      this.onTap,
      this.iconColor});

  final String title;
  final VoidCallback? onTap;
  final Color? iconColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.secondary,
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        onTap: onTap,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/database.dart';
import '/screens/all_students/students_screen.dart';
import '/screens/login/login_screen.dart';
import '/screens/q_and_a/q_and_a_screen.dart';
import '../models/enum.dart';
import '../models/student.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key, this.student});

  final Student? student;

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
                  title: 'Élèves',
                  icon: Icons.person,
                  onTap: () => Navigator.of(context)
                      .pushNamed(StudentsScreen.routeName)),
            if (userType == UserType.teacher)
              MenuItem(
                  title: 'Gestion des questions',
                  icon: Icons.question_answer,
                  onTap: () =>
                      Navigator.of(context).pushNamed(QAndAScreen.routeName)),
            MenuItem(
                title: 'Déconnexion',
                icon: Icons.exit_to_app,
                onTap: () => Navigator.of(context)
                    .pushReplacementNamed(LoginScreen.routeName)),
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

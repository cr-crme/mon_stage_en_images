import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/enum.dart';
import '../models/student.dart';
import '../providers/login_information.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/q_and_a/q_and_a_screen.dart';
import '../../screens/all_students/students_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key, this.student}) : super(key: key);

  final Student? student;

  @override
  Widget build(BuildContext context) {
    final loginType =
        Provider.of<LoginInformation>(context, listen: false).loginType;

    return Drawer(
      child: Scaffold(
        appBar:
            AppBar(title: const Text('Menu principal'), leading: Container()),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (loginType == LoginType.student)
              MenuItem(
                  title: 'Retour',
                  onTap: () => Navigator.of(context).pushReplacementNamed(
                      QAndAScreen.routeName,
                      arguments: student)),
            if (loginType == LoginType.teacher)
              MenuItem(
                  title: 'Élèves',
                  onTap: () => Navigator.of(context)
                      .pushNamed(StudentsScreen.routeName)),
            if (loginType == LoginType.teacher)
              MenuItem(
                  title: 'Gestion des questions',
                  onTap: () =>
                      Navigator.of(context).pushNamed(QAndAScreen.routeName)),
            MenuItem(
                title: 'Déconnexion',
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

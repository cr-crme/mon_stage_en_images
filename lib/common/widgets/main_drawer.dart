import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/enum.dart';
import '../models/student.dart';
import '../providers/login_information.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/student_info/student_screen.dart';
import '../../screens/all_students/students_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key, this.student}) : super(key: key);

  final Student? student;

  @override
  Widget build(BuildContext context) {
    final userIsStudent =
        Provider.of<LoginInformation>(context, listen: false).loginType ==
            LoginType.student;

    return Drawer(
      child: Scaffold(
        appBar:
            AppBar(title: const Text('Menu principal'), leading: Container()),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userIsStudent)
              MenuItem(
                  title: 'Retour',
                  onTap: () => Navigator.of(context).pushReplacementNamed(
                      StudentScreen.routeName,
                      arguments: student)),
            if (!userIsStudent)
              MenuItem(
                  title: 'Élèves',
                  onTap: () => Navigator.of(context)
                      .pushNamed(StudentsScreen.routeName)),
            if (!userIsStudent)
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

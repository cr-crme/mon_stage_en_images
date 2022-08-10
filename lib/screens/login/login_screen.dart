import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../all_students/students_screen.dart';
import '../q_and_a/q_and_a_screen.dart';
import '../../common/models/enum.dart';
import '../../common/models/exceptions.dart';
import '../../common/models/themes.dart';
import '../../common/providers/all_students.dart';
import '../../common/providers/login_information.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const routeName = '/login-screen';

  void _proceedToNextScreen(BuildContext context, LoginType loginType) {
    final theme = Provider.of<LoginInformation>(context, listen: false);

    switch (loginType) {
      case LoginType.student:
        final students = Provider.of<AllStudents>(context, listen: false);
        theme.login('Eleve', LoginType.student);
        Navigator.of(context).pushReplacementNamed(QAndAScreen.routeName,
            arguments: students[0]);
        break;
      case LoginType.teacher:
        theme.login('Professeur', LoginType.teacher);
        Navigator.of(context).pushReplacementNamed(StudentsScreen.routeName);
        break;
      default:
        throw const NotLoggedIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Se connecter en tant que...'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      _proceedToNextScreen(context, LoginType.student),
                  style: ElevatedButton.styleFrom(
                      primary: studentTheme().colorScheme.primary),
                  child: const Text('Élève'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: teacherTheme().colorScheme.primary),
                  onPressed: () =>
                      _proceedToNextScreen(context, LoginType.teacher),
                  child: const Text('Enseignant'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

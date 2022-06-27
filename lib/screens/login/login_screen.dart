import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../all_students/students_screen.dart';
import '../../common/models/enum.dart';
import '../../common/models/exceptions.dart';
import '../../common/providers/theme_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const routeName = '/login-screen';

  void _proceedToNextScreen(BuildContext context, LoginType loginType) {
    final theme = Provider.of<ThemeProvider>(context, listen: false);

    switch (loginType) {
      case LoginType.student:
        theme.changeTheme(LoginType.student);
        Navigator.of(context).pushReplacementNamed(StudentsScreen.routeName);
        break;
      case LoginType.teacher:
        theme.changeTheme(LoginType.teacher);
        Navigator.of(context).pushReplacementNamed(StudentsScreen.routeName);
        break;
      default:
        throw const NotImplemented('This theme is not implemented yet');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(children: [
          ElevatedButton(
            onPressed: () => _proceedToNextScreen(context, LoginType.student),
            child: const Text('coucou'),
          )
        ]),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.of(context).pushReplacementNamed(StudentsScreen.routeName);
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/models/user.dart';
import '../q_and_a/q_and_a_screen.dart';
import '../all_students/students_screen.dart';
import '../../common/models/enum.dart';
import '../../common/models/themes.dart';
import '../../common/providers/all_students.dart';
import '../../common/providers/login_information.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const routeName = '/login-screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;
  LoginStatus _loginStatus = LoginStatus.waitingForLogin;

  Future<void> _proceedToNextScreen(LoginType loginType) async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final navigator = Navigator.of(context);
    final students = Provider.of<AllStudents>(context, listen: false);
    final logger = Provider.of<LoginInformation>(context, listen: false);
    final user = User(email: _email!);
    _loginStatus = await logger.login(context,
        user: user, password: _password!, loginType: loginType);
    if (_loginStatus != LoginStatus.connected) {
      setState(() {});
      return;
    }

    if (loginType == LoginType.student) {
      navigator.pushReplacementNamed(QAndAScreen.routeName,
          arguments: students[0]);
    } else if (loginType == LoginType.teacher) {
      navigator.pushReplacementNamed(StudentsScreen.routeName);
    } else {
      _loginStatus = LoginStatus.unrecognizedError;
    }
  }

  String _loginStatusToString() {
    if (_loginStatus == LoginStatus.waitingForLogin) {
      return '';
    } else if (_loginStatus == LoginStatus.connected) {
      return '';
    } else if (_loginStatus == LoginStatus.wrongUsername) {
      return 'Utilisateur non enregistré';
    } else if (_loginStatus == LoginStatus.wrongPassword) {
      return 'Mot de passe non reconnu';
    } else if (_loginStatus == LoginStatus.unrecognizedError) {
      return 'Erreur de connexion inconnue';
    } else {
      throw TypeException('Unrecognized status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'DÉFI',
                            style: TextStyle(
                                fontSize: 40,
                                color: teacherTheme().colorScheme.primary),
                          ),
                          const SizedBox(width: 15),
                          Text(
                            'PHOTO',
                            style: TextStyle(
                                fontSize: 40,
                                color: studentTheme().colorScheme.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          Text(
                            'Informations de connexion',
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Courriel'),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Inscrire un courriel'
                              : null,
                          onSaved: (value) => _email = value,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Mot de passe'),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Entrer le mot de passe'
                              : null,
                          onSaved: (value) => _password = value,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          keyboardType: TextInputType.visiblePassword,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          Text(
                            'Se connecter en tant que...',
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () =>
                                _proceedToNextScreen(LoginType.student),
                            style: ElevatedButton.styleFrom(
                                primary: studentTheme().colorScheme.primary),
                            child: Text(
                              'Élève',
                              style: TextStyle(
                                color: studentTheme().colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: teacherTheme().colorScheme.primary),
                            onPressed: () =>
                                _proceedToNextScreen(LoginType.teacher),
                            child: Text(
                              'Enseignant',
                              style: TextStyle(
                                color: teacherTheme().colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_loginStatus != LoginStatus.waitingForLogin ||
                          _loginStatus != LoginStatus.connected)
                        const SizedBox(height: 15),
                      if (_loginStatus != LoginStatus.waitingForLogin ||
                          _loginStatus != LoginStatus.connected)
                        Text(
                          _loginStatusToString(),
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

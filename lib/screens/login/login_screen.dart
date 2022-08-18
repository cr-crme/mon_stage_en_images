import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  AllStudents? _allStudents;
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;
  LoginStatus _loginStatus = LoginStatus.waitingForLogin;
  LoginInformation? _logger;

  Future<void> _proceedToNextScreen() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    _logger = Provider.of<LoginInformation>(context, listen: false);
    _loginStatus =
        await _logger!.login(context, email: _email!, password: _password!);
    setState(() {});
  }

  String _loginStatusToString() {
    if (_loginStatus == LoginStatus.waitingForLogin) {
      return '';
    } else if (_loginStatus == LoginStatus.signedIn) {
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

  void logAsStudent() {
    if (_logger == null || _loginStatus != LoginStatus.signedIn) return;

    if (_logger!.user!.isStudent) {
      Navigator.of(context).pushReplacementNamed(QAndAScreen.routeName);
    } else {
      Navigator.of(context).pushReplacementNamed(StudentsScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    _allStudents = Provider.of<AllStudents>(context, listen: true);
    if (_allStudents!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => logAsStudent());
    }
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
                      ElevatedButton(
                        onPressed: () => _proceedToNextScreen(),
                        style: ElevatedButton.styleFrom(
                            primary: teacherTheme().colorScheme.primary),
                        child: Text(
                          'Se connecter',
                          style: TextStyle(
                            color: teacherTheme().colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      if (_loginStatus != LoginStatus.waitingForLogin ||
                          _loginStatus != LoginStatus.signedIn)
                        const SizedBox(height: 15),
                      if (_loginStatus != LoginStatus.waitingForLogin ||
                          _loginStatus != LoginStatus.signedIn)
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

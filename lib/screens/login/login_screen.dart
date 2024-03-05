import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/models/database.dart';
import 'package:mon_stage_en_images/common/models/enum.dart';
import 'package:mon_stage_en_images/common/models/themes.dart';
import 'package:mon_stage_en_images/common/models/user.dart';
import 'package:mon_stage_en_images/common/providers/all_questions.dart';
import 'package:mon_stage_en_images/default_questions.dart';
import 'package:mon_stage_en_images/screens/login/go_to_irsst_screen.dart';
import 'package:mon_stage_en_images/screens/login/widgets/change_password_alert_dialog.dart';
import 'package:mon_stage_en_images/screens/login/widgets/main_title_background.dart';
import 'package:mon_stage_en_images/screens/login/widgets/new_user_alert_dialog.dart';
import 'package:mon_stage_en_images/screens/q_and_a/q_and_a_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login-screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;
  EzloginStatus _status = EzloginStatus.none;
  bool _isNewUser = false;

  @override
  void initState() {
    super.initState();
    _processConnexion(automaticConnexion: true);
  }

  Future<User?> _createUser(String email) async {
    final user = await showDialog<User>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return NewUserAlertDialog(email: email);
      },
    );
    _isNewUser = true;
    return user;
  }

  Future<String> _changePassword() async {
    final password = await showDialog<String>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return const ChangePasswordAlertDialog();
      },
    );
    return password!;
  }

  void _showSnackbar() {
    late final String message;
    if (_status == EzloginStatus.waitingForLogin) {
      message = '';
    } else if (_status == EzloginStatus.cancelled) {
      message = 'La connexion a été annulée';
    } else if (_status == EzloginStatus.success) {
      message = '';
    } else if (_status == EzloginStatus.wrongUsername) {
      message = 'Utilisateur non enregistré';
    } else if (_status == EzloginStatus.wrongPassword) {
      message = 'Mot de passe non reconnu';
    } else {
      message = 'Erreur de connexion inconnue';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _processConnexion({bool automaticConnexion = false}) async {
    setState(() => _status = EzloginStatus.waitingForLogin);
    final database = Provider.of<Database>(context, listen: false);

    if (automaticConnexion) {
      if (database.currentUser == null) {
        setState(() => _status = EzloginStatus.none);
        return;
      }
      _status = EzloginStatus.success;
    } else {
      if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
        setState(() => _status = EzloginStatus.cancelled);
        return;
      }
      _formKey.currentState!.save();

      _status = await database.login(
        username: _email!,
        password: _password!,
        getNewUserInfo: () => _createUser(_email!),
        getNewPassword: _changePassword,
      );
      if (_status != EzloginStatus.success) {
        _showSnackbar();
        setState(() {});
        return;
      }
      if (!mounted) return;
    }

    if (database.currentUser!.userType == UserType.student) {
      Future.delayed(
          Duration(seconds: automaticConnexion ? 2 : 0),
          () => Navigator.of(context).pushReplacementNamed(
              QAndAScreen.routeName,
              arguments: [Target.individual, PageMode.editableView, null]));
    } else {
      if (_isNewUser) {
        final questions = Provider.of<AllQuestions>(context, listen: false);
        for (final question in DefaultQuestion.questions) {
          questions.add(question);
        }
      }
      Future.delayed(
          Duration(seconds: automaticConnexion ? 2 : 0),
          () => Navigator.of(context)
              .pushReplacementNamed(GoToIrsstScreen.routeName));
    }
  }

  Widget _buildPage() {
    switch (_status) {
      case EzloginStatus.success:
        return Column(
          children: [
            CircularProgressIndicator(
              color: teacherTheme().colorScheme.primary,
            ),
            const Text('Connexion en cours...', style: TextStyle(fontSize: 18)),
          ],
        );
      case EzloginStatus.newUser:
      case EzloginStatus.waitingForLogin:
      case EzloginStatus.alreadyCreated:
        return CircularProgressIndicator(
          color: teacherTheme().colorScheme.primary,
        );
      case EzloginStatus.none:
      case EzloginStatus.cancelled:
      case EzloginStatus.wrongUsername:
      case EzloginStatus.wrongPassword:
      case EzloginStatus.wrongInfoWhileCreating:
      case EzloginStatus.couldNotCreateUser:
      case EzloginStatus.needAuthentication:
      case EzloginStatus.userNotFound:
      case EzloginStatus.unrecognizedError:
        return Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Informations de connexion',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Courriel'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Inscrire un courriel'
                          : null,
                      onSaved: (value) => _email = value,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _processConnexion,
              style: ElevatedButton.styleFrom(
                  backgroundColor: studentTheme().colorScheme.primary),
              child: const Text('Se connecter'),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: MainTitleBackground(child: _buildPage()),
        ),
      ),
    );
  }
}

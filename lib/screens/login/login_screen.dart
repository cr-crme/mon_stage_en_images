import 'package:defi_photo/common/models/database.dart';
import 'package:defi_photo/common/models/enum.dart';
import 'package:defi_photo/common/models/themes.dart';
import 'package:defi_photo/common/models/user.dart';
import 'package:defi_photo/common/providers/all_answers.dart';
import 'package:defi_photo/common/providers/all_questions.dart';
import 'package:defi_photo/common/widgets/colored_corners.dart';
import 'package:defi_photo/default_questions.dart';
import 'package:defi_photo/screens/all_students/students_screen.dart';
import 'package:defi_photo/screens/login/widgets/change_password_alert_dialog.dart';
import 'package:defi_photo/screens/login/widgets/new_user_alert_dialog.dart';
import 'package:defi_photo/screens/q_and_a/q_and_a_screen.dart';
import 'package:flutter/material.dart';
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
  Future<EzloginStatus>? _futureStatus;
  bool _isNewUser = false;

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

  void _showSnackbar(EzloginStatus status, ScaffoldMessengerState scaffold) {
    late final String message;
    if (status == EzloginStatus.waitingForLogin) {
      message = '';
    } else if (status == EzloginStatus.cancelled) {
      message = 'La connexion a été annulée';
    } else if (status == EzloginStatus.success) {
      message = '';
    } else if (status == EzloginStatus.wrongUsername) {
      message = 'Utilisateur non enregistré';
    } else if (status == EzloginStatus.wrongPassword) {
      message = 'Mot de passe non reconnu';
    } else {
      message = 'Erreur de connexion inconnue';
    }

    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<EzloginStatus> _processConnexion() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return EzloginStatus.cancelled;
    }
    _formKey.currentState!.save();

    final scaffold = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final database = Provider.of<Database>(context, listen: false);

    final status = await database.login(
      username: _email!,
      password: _password!,
      getNewUserInfo: () => _createUser(_email!),
      getNewPassword: _changePassword,
    );
    setState(() {});
    if (status != EzloginStatus.success) {
      _showSnackbar(status, scaffold);
      return status;
    }

    _startFetchingData();

    if (database.currentUser!.userType == UserType.student) {
      _waitingRoomForStudent();
    } else {
      if (mounted && _isNewUser) {
        final questions = Provider.of<AllQuestions>(context, listen: false);
        for (final question in DefaultQuestion.questions) {
          questions.add(question);
        }
      }
      navigator.pushReplacementNamed(StudentsScreen.routeName);
    }
    return status;
  }

  void _startFetchingData() {
    /// this should be call only after user has successfully logged in
    final allAnswers = Provider.of<AllAnswers>(context, listen: false);
    final questions = Provider.of<AllQuestions>(context, listen: false);

    allAnswers.initializeFetchingData();
    questions.initializeFetchingData();
  }

  void _waitingRoomForStudent() {
    if (!mounted) return;
    final db = Provider.of<Database>(context, listen: false);
    final students = db.myStudents.toList();

    // Wait until the data are fetched
    if (students.indexWhere((e) => e.id == db.currentUser!.studentId) < 0) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _waitingRoomForStudent());
      return;
    }

    Navigator.of(context).pushReplacementNamed(QAndAScreen.routeName,
        arguments: [Target.individual, PageMode.editableView, null]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: ColoredCorners(
            firstColor: LinearGradient(
              end: const Alignment(0, 0.6),
              begin: const Alignment(0.5, 1.5),
              colors: [
                teacherTheme().colorScheme.primary,
                Colors.white,
              ],
            ),
            secondColor: LinearGradient(
              begin: const Alignment(-0.1, -1),
              end: const Alignment(0, -0.6),
              colors: [
                studentTheme().colorScheme.primary,
                Colors.white10,
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const MainTitle(),
                const SizedBox(height: 50),
                FutureBuilder<EzloginStatus>(
                    future: _futureStatus,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(
                          color: teacherTheme().colorScheme.primary,
                        );
                      }

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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: 'Courriel'),
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                            ? 'Inscrire un courriel'
                                            : null,
                                    onSaved: (value) => _email = value,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: 'Mot de passe'),
                                    validator: (value) =>
                                        value == null || value.isEmpty
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
                            onPressed: () {
                              _futureStatus = _processConnexion();
                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    studentTheme().colorScheme.primary),
                            child: const Text('Se connecter'),
                          ),
                        ],
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainTitle extends StatelessWidget {
  const MainTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: FractionalOffset.center,
      transform: Matrix4.identity()..rotateZ(-15 * 3.1415927 / 180),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ColoredBox(
            color: studentTheme().colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'DÉFI',
                style: TextStyle(
                    fontSize: 40, color: studentTheme().colorScheme.onPrimary),
              ),
            ),
          ),
          ColoredBox(
            color: teacherTheme().colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'PHOTO',
                style: TextStyle(
                    fontSize: 40, color: teacherTheme().colorScheme.onPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

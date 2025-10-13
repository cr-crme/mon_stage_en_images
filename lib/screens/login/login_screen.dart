import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:mon_stage_en_images/common/models/database.dart';
import 'package:mon_stage_en_images/common/models/enum.dart';
import 'package:mon_stage_en_images/common/models/text_reader.dart';
import 'package:mon_stage_en_images/common/models/themes.dart';
import 'package:mon_stage_en_images/common/models/user.dart';
import 'package:mon_stage_en_images/common/providers/all_questions.dart';
import 'package:mon_stage_en_images/default_questions.dart';
import 'package:mon_stage_en_images/main.dart';
import 'package:mon_stage_en_images/screens/login/terms_and_services_screen.dart';
import 'package:mon_stage_en_images/screens/login/widgets/change_password_alert_dialog.dart';
import 'package:mon_stage_en_images/screens/login/widgets/forgot_password_alert_dialog.dart';
import 'package:mon_stage_en_images/screens/login/widgets/main_title_background.dart';
import 'package:mon_stage_en_images/screens/login/widgets/new_user_alert_dialog.dart';
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
  bool _hidePassword = true;

  final _textReader = TextReader();

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

      _status = await database
          .login(
        username: _email!,
        password: _password!,
        getNewUserInfo: () => _createUser(_email!),
        getNewPassword: _changePassword,
      )
          .then(
        (value) {
          debugPrint("$value login is complete");
          return value;
        },
      );
      if (_status != EzloginStatus.success) {
        _showSnackbar();
        setState(() {});
        return;
      }
      if (!mounted) return;
    }

    if (_isNewUser && database.currentUser!.userType == UserType.teacher) {
      final questions = Provider.of<AllQuestions>(context, listen: false);
      for (final question in DefaultQuestion.questions) {
        questions.add(question);
      }
    }
    Future.delayed(Duration(seconds: automaticConnexion ? 2 : 0), () {
      if (!mounted) return;
      rootNavigatorKey.currentState
          ?.pushReplacementNamed(TermsAndServicesScreen.routeName);
      // Navigator.of(context)
      //     .pushReplacementNamed(TermsAndServicesScreen.routeName);
    });
  }

  Future<void> _showForgotPasswordDialog(email) async {
    await showDialog<bool?>(
      context: context,
      builder: (context) => ForgotPasswordAlertDialog(email: email),
    ).then((response) {
      if (response != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(response
                ? "Un courriel de réinitialisation a été envoyé à l'adresse fournie, si elle correspond à un compte utilisateur"
                : "Une erreur est survenue, le courriel de réinitialisation n'a pas pu être envoyé."),
            backgroundColor: response
                ? Theme.of(context).snackBarTheme.backgroundColor
                : Theme.of(context).colorScheme.error));
      }
    });
  }

  Future<void> _newTeacher() async {
    const studentTextPart =
        'Si vous êtes un ou une élève, veuillez attendre que votre enseignant ou enseignante vous inscrive.';
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Inscription'),
                IconButton(
                    onPressed: () => _textReader.readText(
                          'Inscription.\n$studentTextPart',
                          hasFinishedCallback: () => _textReader.stopReading(),
                        ),
                    icon: const Icon(Icons.volume_up))
              ],
            ),
            content: Text.rich(TextSpan(children: [
              const TextSpan(
                text: 'Si vous êtes un(e) enseignant(e), vous pouvez faire '
                    'la demande pour un compte en remplissant ',
              ),
              TextSpan(
                text: 'ce formulaire',
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    final email = Email(
                        recipients: ['recherchetic@gmail.com'],
                        subject: 'Mon stage en images - Inscription',
                        body:
                            'Bonjour,\n\nJe suis un(e) enseignant(e) et je souhaite utiliser '
                            '« Mon stage en images ». Voici mes informations :\n\n'
                            'Mes informations :\n'
                            '    Commission scolaire : INSCRIRE VOTRE COMMISSION SCOLAIRE\n'
                            '    Nom de l\'école : INSCRIRE LE NOM DE VOTRE ÉCOLE\n'
                            '    Indentifiant : INSCRIRE UN IDENTIFIANT À VOTRE COMMISSION SCOLAIRE QUI NOUS PERMETTRA DE VOUS IDENTIFIER\n'
                            '    Courriel : INSCRIRE UN COURRIEL VALIDE\n\n'
                            'Merci de votre aide.');
                    await FlutterEmailSender.send(email);
                  },
                style: const TextStyle(
                    color: Colors.blue, decoration: TextDecoration.underline),
              ),
              const TextSpan(text: '.\n\n$studentTextPart'),
            ]))));
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
        return SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 500),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Informations de connexion',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Courriel'),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Inscrire un courriel'
                              : null,
                          onSaved: (value) => _email = value,
                          initialValue: _email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              suffixIcon: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: IconButton.outlined(
                                    onPressed: () {
                                      _hidePassword = !_hidePassword;
                                      setState(() {});
                                    },
                                    icon: Icon(_hidePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off)),
                              )),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Entrer le mot de passe'
                              : null,
                          onSaved: (value) => _password = value,
                          obscureText: _hidePassword,
                          enableSuggestions: false,
                          autocorrect: false,
                          keyboardType: TextInputType.visiblePassword,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                              onPressed: () {
                                _formKey.currentState?.save();
                                _showForgotPasswordDialog(_email);
                              },
                              child: Text(
                                'Mot de passe oublié',
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold),
                              )),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    // FilledButton(
                    //     onPressed: () async {}, child: Text('Test onboarding')),
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _processConnexion,
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                studentTheme().colorScheme.primary),
                        child: const Text('Se connecter'),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _newTeacher,
                        child: const Text('Nouvel(le) utilisateur(trice)'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainTitleBackground(child: _buildPage()),
    );
  }
}

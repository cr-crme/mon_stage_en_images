import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:mon_stage_en_images/common/models/database.dart';
import 'package:mon_stage_en_images/main.dart';
import 'package:mon_stage_en_images/screens/login/login_screen.dart';
import 'package:mon_stage_en_images/screens/login/widgets/main_title_background.dart';
import 'package:provider/provider.dart';

class CheckVersionScreen extends StatelessWidget {
  const CheckVersionScreen({super.key});

  static const routeName = '/check-version-screen';

  Future<bool> _checkSoftwareVersion(context) async {
    // Check the software version
    final requiredVersion = await Provider.of<Database>(context, listen: false)
        .getRequiredSoftwareVersion();
    return requiredVersion == softwareVersion;
  }

  @override
  Widget build(context) {
    return Scaffold(
      body: Center(
        child: MainTitleBackground(
            child: FutureBuilder(
                future: _checkSoftwareVersion(context),
                builder: ((context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Column(
                      children: [
                        CircularProgressIndicator(),
                        Text('Vérification de la version...',
                            style: TextStyle(fontSize: 18)),
                      ],
                    );
                  }

                  if (snapshot.data == null) {
                    return Text.rich(TextSpan(children: [
                      const TextSpan(
                          text:
                              'Une erreur s\'est produite lors de la lecture du numéro de version. '
                              'SVP, contacter le soutien technique à l\'adresse suivante : '),
                      TextSpan(
                        text: 'recherchetic@gmail.com',
                        style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            await FlutterEmailSender.send(Email(
                                recipients: ['recherchetic@gmail.com'],
                                subject:
                                    'Mon stage en images - Problème de connexion'));
                          },
                      ),
                      const TextSpan(text: '.')
                    ]));
                  }

                  // If the version is valid
                  if (snapshot.data == true) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      debugPrint(
                          "will navigato to LoginScreen from CheckVersionScreen");
                      rootNavigatorKey.currentState
                          ?.pushReplacementNamed(LoginScreen.routeName);
                      // Navigator.of(context)
                      //     .pushReplacementNamed(LoginScreen.routeName);
                    });
                  }
                  // Tell the user their version is obsolete so they have to download the latest
                  // version from the Apple or Google store
                  return const Text(
                      'La version de l\'application est obsolète. '
                      'Veuillez télécharger la dernière mise à jour '
                      'sur App Store ou Google Play Store.',
                      style: TextStyle(fontSize: 18));
                }))),
      ),
    );
  }
}

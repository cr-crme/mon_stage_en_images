import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/models/themes.dart';
import 'package:mon_stage_en_images/main.dart';
import 'package:mon_stage_en_images/screens/all_students/students_screen.dart';
import 'package:mon_stage_en_images/screens/login/widgets/main_title_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class GoToIrsstScreen extends StatelessWidget {
  const GoToIrsstScreen({super.key});

  static const routeName = '/go-to-irsst-screen';

  static final url = Uri(
    scheme: 'https',
    host: 'www.irsst.qc.ca',
    path:
        'publications-et-outils/publication/i/101076/n/sst-supervision-de-stages-',
  );

  final sharedPrefName = 'hasAlreadySeenTheIrrstPage';

  Future<bool> _haveAlreadySeenThePage(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (context.mounted && (prefs.getBool(sharedPrefName) ?? false)) {
      _continueToApp(context);
    }
    await prefs.setBool(sharedPrefName, true);

    return false;
  }

  Future<void> _goVisitWebSite(BuildContext context) async {
    await launchUrl(url);
    if (!context.mounted) return;
    _continueToApp(context);
  }

  Future<void> _continueToApp(BuildContext context) async {
    if (!context.mounted) return;
    rootNavigatorKey.currentState
        ?.pushReplacementNamed(StudentsScreen.routeName);
    // Navigator.of(context).pushReplacementNamed(StudentsScreen.routeName);
  }

  @override
  Widget build(context) {
    return Scaffold(
      body: Center(
        child: MainTitleBackground(
            child: FutureBuilder<bool>(
                future: _haveAlreadySeenThePage(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Container();
                  }

                  return Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                          'Vous trouverez des informations utiles et ludiques '
                          'concernant la Santé et sécurité au travail (SST) en '
                          'suivant ce lien. Vous pouvez accéder à ce lien à '
                          'partir de l\'application en tout temps en cliquant '
                          'sur le bouton "IRSST" dans le menu principal. ',
                          style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => _goVisitWebSite(context),
                            style: studentTheme().elevatedButtonTheme.style,
                            child: const Text('Visiter le site web'),
                          ),
                          ElevatedButton(
                              onPressed: () => _continueToApp(context),
                              style: studentTheme().elevatedButtonTheme.style,
                              child: const Text('Continuer')),
                        ],
                      )
                    ],
                  );
                })),
      ),
    );
  }
}

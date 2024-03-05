import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/models/database.dart';
import 'package:mon_stage_en_images/common/models/enum.dart';
import 'package:mon_stage_en_images/common/models/text_reader.dart';
import 'package:mon_stage_en_images/common/models/themes.dart';
import 'package:mon_stage_en_images/screens/login/go_to_irsst_screen.dart';
import 'package:mon_stage_en_images/screens/login/widgets/main_title_background.dart';
import 'package:mon_stage_en_images/screens/q_and_a/q_and_a_screen.dart';
import 'package:provider/provider.dart';

class TermsAndServicesScreen extends StatelessWidget {
  const TermsAndServicesScreen({super.key});

  static const routeName = '/terms-and-services-screen';

  final sharedPrefName = 'hasAlreadyAcceptedTermsAndServices';

  Future<bool> _haveAlreadyAcceptedTermsAndServices(context) async {
    if (Provider.of<Database>(context, listen: false)
        .currentUser!
        .termsAndServicesAccepted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _continueToApp(context);
      });
      return true;
    }
    return false;
  }

  Future<void> _acceptTermsAndServices(context) async {
    final database = Provider.of<Database>(context, listen: false);
    final user = database.currentUser!;
    await database.modifyUser(
        user: user, newInfo: user.copyWith(termsAndServicesAccepted: true));

    _continueToApp(context);
  }

  Future<void> _continueToApp(BuildContext context) async {
    if (!context.mounted) return;

    final user = Provider.of<Database>(context, listen: false).currentUser!;
    if (user.userType == UserType.student) {
      Navigator.of(context).pushReplacementNamed(QAndAScreen.routeName,
          arguments: [Target.individual, PageMode.editableView, null]);
    } else {
      Navigator.of(context).pushReplacementNamed(GoToIrsstScreen.routeName);
    }
  }

  @override
  Widget build(context) {
    const termsAndServicesText =
        'En cliquant sur « Accepter », vous acceptez d\'utiliser l\'application '
        '« Mon stage en image » et la messagerie qui y est intégrée de façon '
        'responsable et respectueuse. Il est interdit d\'y tenir des propos '
        'offensants ou de partager des images inappropriées avec la fonction '
        'de partage d\'images.\n\n'
        'Ne pas respecter ces conditions pourrait entraîner des '
        'sanctions allant jusqu\'à la suspension de votre compte.';

    return Scaffold(
      body: Center(
        child: MainTitleBackground(
            child: FutureBuilder<bool>(
                future: _haveAlreadyAcceptedTermsAndServices(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Container();
                  }

                  return Column(
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Conditions d\'utilisation',
                              style: TextStyle(fontSize: 24)),
                          IconButton(
                              onPressed: () {
                                final textReader = TextReader();
                                textReader.readText(
                                  'Conditions d\'utilisation.\n$termsAndServicesText\n'
                                  'Cliquez sur « Accepter les conditions » si vous acceptez.',
                                  hasFinishedCallback: () =>
                                      textReader.stopReading(),
                                );
                              },
                              icon: const Icon(Icons.volume_up))
                        ],
                      ),
                      const Text(termsAndServicesText),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                              onPressed: () => _acceptTermsAndServices(context),
                              style: studentTheme().elevatedButtonTheme.style,
                              child: const Text('Accepter les conditions')),
                        ],
                      )
                    ],
                  );
                })),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/helpers/responsive_service.dart';
import 'package:mon_stage_en_images/common/helpers/route_manager.dart';
import 'package:mon_stage_en_images/common/models/themes.dart';
import 'package:mon_stage_en_images/common/providers/database.dart';
import 'package:mon_stage_en_images/screens/login/widgets/main_title_background.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class GoToIrsstScreen extends StatelessWidget {
  const GoToIrsstScreen({super.key});

  static const routeName = '/go-to-irsst-screen';

  static final learnAboutSstUri = Uri(
    scheme: 'https',
    host: 'monstageenimages.adoprevit.org',
    path: 'resources/ApprendreSST.pdf',
  );

  static final learnAboutMetierUri = Uri(
    scheme: 'https',
    host: 'monstageenimages.adoprevit.org',
    path: 'resources/ApprendreMETIER.pdf',
  );
  static final learnAboutApp = Uri(
    scheme: 'https',
    host: 'adoprevit.org',
    path: 'stage-en-images',
  );

  @override
  Widget build(context) {
    return Scaffold(
      body: Center(
        child: MainTitleBackground(
            child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: ResponsiveService.smallScreenWidth),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                  'L\'application Stage en Images est conçue pour '
                  'être utilisée après une phase préliminaire d\'analyse de l\'activité de travail '
                  'avec vos élèves. Consultez nos ressources pour la prise en main, '
                  'des conseils et du dépannage technique en utlisant le lien ci-dessous.',
                  style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async => await launchUrl(learnAboutApp),
                    style: studentTheme().elevatedButtonTheme.style,
                    label: const Text('Voir la présentation'),
                    icon: const Icon(Icons.open_in_new),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        final database =
                            Provider.of<Database>(context, listen: false);
                        final user = database.currentUser;
                        if (user == null) return;
                        await database.modifyUser(
                            user: user,
                            newInfo: user.copyWith(irsstPageSeen: true));

                        if (!context.mounted) return;
                        RouteManager.instance.gotoStudentsPage(context);
                      },
                      style: studentTheme().elevatedButtonTheme.style,
                      child: const Text('Continuer')),
                ],
              )
            ],
          ),
        )),
      ),
    );
  }
}

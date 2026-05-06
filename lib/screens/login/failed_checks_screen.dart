import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/screens/login/widgets/main_title_background.dart';

class FailedChecksScreen extends StatelessWidget {
  const FailedChecksScreen({super.key});

  static const routeName = '/failed-check-screen';

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;

    return Scaffold(
      body: MainTitleBackground(
        child: Column(
          children: [
            Icon(
              Icons.wifi_off,
              size: 60,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
                'Stage en images n\'a pas pu effectuer les vérifications'
                ' nécessaires à son lancement.',
                style: textStyle),
            SizedBox(
              height: 20,
            ),
            Text(
              'Vérifiez votre accès à Internet, puis fermez et relancez l\'application',
              style: textStyle,
            )
          ],
        ),
      ),
    );
  }
}

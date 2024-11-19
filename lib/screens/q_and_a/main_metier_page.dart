import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/models/database.dart';
import 'package:mon_stage_en_images/common/models/enum.dart';
import 'package:mon_stage_en_images/common/models/user.dart';
import 'package:mon_stage_en_images/screens/q_and_a/widgets/metier_tile.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MainMetierPage extends StatelessWidget {
  const MainMetierPage({
    super.key,
    required this.student,
    required this.onPageChanged,
  });

  static const routeName = '/main-metier-page';
  final User? student;
  final Function(int) onPageChanged;

  @override
  Widget build(BuildContext context) {
    final userType =
        Provider.of<Database>(context, listen: false).currentUser?.userType;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 15),
          if (student != null)
            Text('Résumé des réponses',
                style: Theme.of(context).textTheme.titleLarge),
          if (student != null) const SizedBox(height: 5),
          MetierTile(0, studentId: student?.id, onTap: onPageChanged),
          MetierTile(1, studentId: student?.id, onTap: onPageChanged),
          MetierTile(2, studentId: student?.id, onTap: onPageChanged),
          MetierTile(3, studentId: student?.id, onTap: onPageChanged),
          MetierTile(4, studentId: student?.id, onTap: onPageChanged),
          MetierTile(5, studentId: student?.id, onTap: onPageChanged),
          if (userType == UserType.teacher)
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                  child: RichText(
                      text: TextSpan(children: [
                    const TextSpan(
                      style: TextStyle(color: Colors.black),
                      text:
                          'Vous cherchez des idées pour des questions? Vous pouvez accéder à plus d\'exemples en ',
                    ),
                    TextSpan(
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => launchUrl(Uri(
                              scheme: 'http',
                              host: 'adoprevit.org',
                              path: 'ressources',
                            )),
                      text: 'cliquant ici',
                    ),
                    const TextSpan(
                        text: '.', style: TextStyle(color: Colors.black)),
                  ]))),
            ),
        ],
      ),
    );
  }
}

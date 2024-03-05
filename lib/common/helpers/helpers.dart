import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/models/database.dart';
import 'package:mon_stage_en_images/common/widgets/are_you_sure_dialog.dart';
import 'package:mon_stage_en_images/screens/login/login_screen.dart';
import 'package:provider/provider.dart';

class Helpers {
  static void onClickQuit(BuildContext context) async {
    final navigator = Navigator.of(context);
    final sure = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AreYouSureDialog(
          title: 'Déconnexion',
          content: 'Êtes-vous certain(e) de vouloir vous déconnecter?',
        );
      },
    );

    if (!sure!) {
      return;
    }

    if (!context.mounted) return;
    final database = Provider.of<Database>(context, listen: false);
    await database.logout();
    navigator.pushReplacementNamed(LoginScreen.routeName);
  }
}

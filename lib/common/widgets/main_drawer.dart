import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/helpers/helpers.dart';
import 'package:mon_stage_en_images/common/models/database.dart';
import 'package:mon_stage_en_images/common/models/enum.dart';
import 'package:mon_stage_en_images/onboarding/application/shared_preferences_notifier.dart';
import 'package:mon_stage_en_images/onboarding/data/onboarding_steps_list.dart';
import 'package:mon_stage_en_images/onboarding/widgets/onboarding_target.dart';
import 'package:mon_stage_en_images/screens/all_students/students_screen.dart';
import 'package:mon_stage_en_images/screens/login/go_to_irsst_screen.dart';
import 'package:mon_stage_en_images/screens/q_and_a/q_and_a_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userType =
        Provider.of<Database>(context, listen: false).currentUser?.userType ??
            UserType.student;
    final sharedPrefs =
        Provider.of<SharedPreferencesNotifier>(context, listen: true);

    return Drawer(
      child: Scaffold(
        appBar:
            AppBar(title: const Text('Menu principal'), leading: Container()),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userType == UserType.teacher)
              MenuItem(
                  title: 'Mes élèves',
                  icon: Icons.person,
                  onTap: () => Navigator.of(context)
                      .pushNamed(StudentsScreen.routeName)),
            if (userType == UserType.teacher)
              OnboardingTarget(
                onboardingId: drawerOpened,
                child: MenuItem(
                    title: 'Gestion des questions',
                    icon: Icons.speaker_notes,
                    onTap: () => Navigator.of(context).pushReplacementNamed(
                        QAndAScreen.routeName,
                        arguments: [Target.all, PageMode.edit, null])),
              ),
            if (userType == UserType.teacher) const Divider(),
            if (userType == UserType.teacher)
              OnboardingTarget(
                onboardingId: questionsSummary,
                child: MenuItem(
                  title: 'Résumé des réponses',
                  icon: Icons.question_answer,
                  onTap: () => Navigator.of(context).pushReplacementNamed(
                      QAndAScreen.routeName,
                      arguments: [Target.all, PageMode.fixView, null]),
                ),
              ),
            if (userType == UserType.teacher) const Divider(),
            if (userType == UserType.teacher)
              OnboardingTarget(
                onboardingId: learnMore,
                child: MenuItem(
                    title: 'Apprendre sur la SST',
                    icon: Icons.web,
                    onTap: () async {
                      await launchUrl(GoToIrsstScreen.url);
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    }),
              ),
            if (userType == UserType.teacher) const Divider(),
            if (userType == UserType.teacher)
              FutureBuilder(
                  future: sharedPrefs.hasSeenOnboarding,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data == true) {
                      return Column(children: [
                        MenuItem(
                          title: 'Revoir le tutoriel',
                          icon: Icons.help,
                          onTap: () {
                            sharedPrefs.setHasSeenOnboardingTo(!snapshot.data!);
                          },
                        ),
                        const Divider(),
                      ]);
                    }

                    return SizedBox.shrink();
                  }),
            MenuItem(
                title: 'Déconnexion',
                icon: Icons.exit_to_app,
                onTap: () => Helpers.onClickQuit(context)),
          ],
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  const MenuItem(
      {super.key,
      required this.title,
      required this.icon,
      this.onTap,
      this.iconColor});

  final String title;
  final VoidCallback? onTap;
  final Color? iconColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.secondary,
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        onTap: onTap,
      ),
    );
  }
}

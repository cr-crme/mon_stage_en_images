import 'package:flutter/widgets.dart';
import 'package:mon_stage_en_images/common/models/enum.dart';
import 'package:mon_stage_en_images/onboarding/models/onboarding_step.dart';
import 'package:mon_stage_en_images/screens/all_students/students_screen.dart';
import 'package:mon_stage_en_images/screens/q_and_a/q_and_a_screen.dart';

const String newQuestion = 'newQuestion';
const String drawer = 'drawer';
const String drawerOpened = 'drawerOpened';
const String metier = 'metier';
const String exampleQuestions = 'examplesQuestions';
const String questionsSummary = 'questionsSummary';
const String learnMore = 'learnMore';

///The onboarding steps to be shown during the onboarding sequence
List<OnboardingStep> onboardingSteps = [
  OnboardingStep(
      routeName: StudentsScreen.routeName,
      targetId: 'add-student',
      message: 'Appuyez ici pour ajouter des élèves'),
  OnboardingStep(
      routeName: StudentsScreen.routeName,
      targetId: drawer,
      message:
          "Appuyez ici pour accéder aux différentes pages de l’application."),
  OnboardingStep(
    routeName: StudentsScreen.routeName,
    targetId: drawerOpened,
    message: "Appuyez ici pour poser une question à vos élèves.",
    prepareNav: (context, outsideState) async {
      final state = outsideState as StudentsScreenState;
      debugPrint("prepareNav for OnboardinStep $drawer running");
      if (state.isDrawerOpen == false) {
        state.openDrawer();
      }
    },
  ),
  OnboardingStep(
      routeName: QAndAScreen.routeName,
      arguments: [Target.all, PageMode.edit, null],
      prepareNav:
          (BuildContext? context, State<StatefulWidget>? outsideState) async {
        final state = outsideState as State<QAndAScreen>;

        debugPrint("prepareNav for OnboardinStep $newQuestion running");

        QAndAScreen.onPageChangedRequestFromOutside(state, 0);
      },
      targetId: metier,
      intermediateId: metier,
      message:
          'Ici, choisissez la section M.É.T.I.E.R. associée à la question à poser'),
  OnboardingStep(
      routeName: QAndAScreen.routeName,
      arguments: [Target.all, PageMode.edit, null],
      prepareNav:
          (BuildContext? context, State<StatefulWidget>? outsideState) async {
        final state = outsideState as State<QAndAScreen>;

        debugPrint("prepareNav for OnboardinStep $newQuestion running");

        QAndAScreen.onPageChangedRequestFromOutside(state, 1);
      },
      targetId: newQuestion,
      intermediateId: newQuestion,
      message: 'Vous pourrez créer une nouvelle question originale'),
  OnboardingStep(
      routeName: QAndAScreen.routeName,
      arguments: [Target.all, PageMode.edit, null],
      prepareNav:
          (BuildContext? context, State<StatefulWidget>? outsideState) async {
        final state = outsideState as State<QAndAScreen>;

        debugPrint("prepareNav for OnboardinStep $exampleQuestions running");

        QAndAScreen.onPageChangedRequestFromOutside(state, 1);
      },
      targetId: exampleQuestions,
      intermediateId: exampleQuestions,
      message: 'Ou en choisir une déjà créée et la modifier'),
  OnboardingStep(
    routeName: StudentsScreen.routeName,
    targetId: questionsSummary,
    message:
        "Sur cette page, vous verrez toutes les réponses à une même question.",
    prepareNav: (context, outsideState) async {
      final state = outsideState as StudentsScreenState;
      debugPrint("prepareNav for OnboardinStep $questionsSummary running");
      if (state.isDrawerOpen == false) {
        state.openDrawer();
      }
    },
  ),
  OnboardingStep(
    routeName: StudentsScreen.routeName,
    targetId: learnMore,
    message: "Vous trouverez ici davantage d'informations et du support.",
    prepareNav: (context, outsideState) async {
      final state = outsideState as StudentsScreenState;
      debugPrint("prepareNav for OnboardinStep $learnMore running");
      if (state.isDrawerOpen == false) {
        state.openDrawer();
      }
    },
  ),
];

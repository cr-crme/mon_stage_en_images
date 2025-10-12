import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/onboarding/application/onboarding_keys_service.dart';

///Represents a step in the onboarding sequence.
class OnboardingStep {
  const OnboardingStep(
      {required this.targetId,
      required this.routeName,
      required this.message,
      this.arguments,
      this.isLast = false,
      this.prepareNav});

  ///The registered route inside which the targeted widget will be highlighted during onboarding
  final String routeName;

  ///Arguments required by the widget to be given to the route
  final Object? arguments;

  ///A string shared by instance of this class and the OnboardingTarget widget to find the targeted widget across the tree.
  ///Link between these objects is permitted by the OnboardingKeysService. targetId Strings are available in the OnboardingStepList.
  final String targetId;

  final bool isLast;

  ///The message to be displayed inside the onboarding dialog for this step
  final String message;

  ///A function to be called by the Onboarding service after the navigation to route is done, if additional
  ///actions are needed in order to allow the targeted widget to be mounted inside the tree. Typically, opening
  ///a drawer or interacting with a controller to jump to a page inside a TabView or PageView.
  final Future<void> Function(
      BuildContext? context, State<StatefulWidget>? state)? prepareNav;

  ///Calls the OnboardingKeysService to retrieve the GlobalKey associated with the targetId
  GlobalKey? get widgetKey =>
      OnboardingKeysService.instance.findTargetKeyWithId(targetId);

  void resetScaffoldElements(
      BuildContext? context, State<StatefulWidget> state) {
    debugPrint("resetScaffoldElements running");
    if (!state.mounted && context == null) return;

    ScaffoldState? scaffoldState;

    if (widgetKey?.currentContext != null) {
      scaffoldState = Scaffold.of(widgetKey!.currentContext!);
    }

    debugPrint("scaffold State is $scaffoldState");
    if (scaffoldState?.isDrawerOpen == true) {
      scaffoldState?.closeDrawer();
    }
  }
}

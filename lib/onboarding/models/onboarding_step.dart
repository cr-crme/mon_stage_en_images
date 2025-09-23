import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/onboarding/application/onboarding_keys_service.dart';

///Represents a step in the onboarding sequence.
class OnboardingStep {
  const OnboardingStep(
      {required this.targetId,
      required this.routeName,
      required this.message,
      this.intermediateId,
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

  ///Currently unused intermediateId (to be paired with IntermediateTarget widget for edge cases scenarios
  /// required additional actions that prepareNav would failed to perform
  final String? intermediateId;

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

  //TODO Peut-être refactoriser rectFromWidget pour le découpler du model OnBoardingStep.
  ///Get the RenderBox from the widgetKey getter, which is linked to the targeted Widget in the tree
  ///Uses the Render Box to draw a Rect with an absolute position on the screen and some padding around.
  Rect? get rectFromWidgetKey {
    final GlobalKey? key = widgetKey;

    if (key?.currentContext == null || !key!.currentContext!.mounted) {
      return null;
    }

    final context = key.currentContext!;
    final widgetObject = context.findRenderObject() as RenderBox;

    final insets = EdgeInsets.all(12);

    final vertOffset = kIsWeb
        ? 0 as double
        : Scaffold.of(context).hasAppBar
            ? MediaQuery.of(context).padding.top + kToolbarHeight
            : MediaQuery.of(context).padding.top;

    final offset = widgetObject.localToGlobal(Offset(0, 0 - vertOffset));
    final size = widgetObject.size;

    return insets.inflateRect(offset & size);
  }
}

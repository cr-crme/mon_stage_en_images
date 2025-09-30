import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/main.dart';
import 'package:mon_stage_en_images/onboarding/application/onboarding_keys_service.dart';
import 'package:mon_stage_en_images/onboarding/application/onboarding_state_notifier.dart';
import 'package:mon_stage_en_images/onboarding/application/shared_preferences_notifier.dart';
import 'package:mon_stage_en_images/onboarding/models/onboarding_step.dart';
import 'package:mon_stage_en_images/onboarding/widgets/onboarding_dialog_clipped_background.dart';
import 'package:provider/provider.dart';

//TODO update comments to match OnboardingStatus enum changes

///Main orchestrator for the Onboarding feature.  instead of a service or Notifier class,
/// it is defined as a SatefulWidget to access some properties of MaterialApp deeper in the tree,
///while allowing a single listening point throughout the app, rather than Consumer on every screen.
///See instanciation in main, inside a Stack Widget.
class OnboardingService extends StatefulWidget {
  const OnboardingService({super.key, required this.child});

  final Widget child;
  @override
  State<OnboardingService> createState() => _OnboardingServiceState();
}

class _OnboardingServiceState extends State<OnboardingService> {
  OnboardingStateNotifier? _onboardingNotifier;

//Using didChangeDependencies since initState doesn't allow for dependencies (context can't be accessed)
  @override
  void didChangeDependencies() {
    debugPrint("didChangeDependencies running in _OnBoardingService");
    final newNotifier = Provider.of<OnboardingStateNotifier>(context);
    // if (!newNotifier.showTutorial) return;
    debugPrint("newNotifier is $newNotifier");
    if (newNotifier != _onboardingNotifier) {
      _onboardingNotifier?.removeListener(_onNotifierChanged);
      _onboardingNotifier = newNotifier;
      _onboardingNotifier?.addListener(_onNotifierChanged);
      debugPrint(
          'listener added on onBoardingNotifier inside didChangeDependencies');
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        Future.microtask(() => _onNotifierChanged());
      },
    );
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _onboardingNotifier?.removeListener(_onNotifierChanged);
    super.dispose();
  }

  ///Called whenever OnboardingStateNotifier notifies a change. Performs a global
  ///check on a boolean value exposed by OnboardingStateNotifier to know if onboarding should be shown
  ///and then proceed to further check by calling _maybeShowStep
  void _onNotifierChanged() {
    debugPrint("_onNotifierChanged running in OnboardingService");
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    final notifier = _onboardingNotifier;
    if (notifier == null || notifier.status != OnboardingStatus.ready) {
      debugPrint(
          "_onNotifierChanged will not trigger _maybeShowStep either because notifier is null or showTutorial property is false."
          " notifier = $notifier and status = ${notifier?.status}");
      return;
    } else {
      _maybeShowStep();
    }
    // });
  }

  void _removeActiveIndex(int index) {
    _onboardingNotifier?.makeStepInactive(index);
  }

  ///Performs check before _showStep is called and mark the current index as active
  ///inside OnboardingStateNotifier, and inactive when _showStep is complete.
  void _maybeShowStep() {
    debugPrint('_maybeShowStep running');
    //If we already are in the process of showing an OnboardingStep, we should return;
    // if (_isActive) return;
    final notifier = _onboardingNotifier;
    if (notifier == null || notifier.status != OnboardingStatus.ready) {
      debugPrint(
          "_maybeShowStep returns either because notifier is null or isOnboardingShowing property is false."
          " notifier = $notifier and isOnboardingShowing = ${notifier?.isOnboardingShowing}");
      return;
    }

    final index = notifier.currentIndex;
    if (index == null) {
      debugPrint("maybeShowStep returns because notifier.currentIndex is null");
      return;
    }

    //We don't want to show our current Step again or the last one.
    if (notifier.stepHasBeenShown(index) || notifier.isStepActive(index)) {
      debugPrint(
          "maybeShowStep returns because the index provided either matches with a step already shown or the step is already active."
          " stepHasBeenShown returns ${notifier.stepHasBeenShown(index)}"
          " notifier.isStepActive returns ${notifier.isStepActive(index)}");
      return;
    }

    //switching our widget state to active to prevent multiple dialog displays

    notifier.makeStepActive(index);
    debugPrint("maybeShowStep : status has become ${notifier.status}");
    _showStep(index).whenComplete(() {
      debugPrint("showStep is complete, status has become ${notifier.status}");
      // _insertClickBarrier();
    });
  }

  Future<void> _showStep(int index) async {
    debugPrint('_showStep running');

    //Checking if our step isn't null and if we should mark its index as inactive
    final notifier = _onboardingNotifier!;
    final step = notifier.currentStep;
    if (step == null) {
      notifier.makeStepInactive(index);
      debugPrint("_showStep will return because currentStep is null");
      return;
    }

    //Navigating to the OnboardingStep Widget's route.

    //Telling the observer through OnboardingStateNotifier that we should ignore
    // the next navigation events, as long as we are in the onboarding sequence.
    notifier.markOnboardingNavigationStart();
    try {
      //Navigate to the screen registered in the onBoardingStep
      //with the rootNavigatorKey, since it is the only global context available
      if (rootNavigatorKey.currentContext == null) {
        debugPrint("rootNavigatorKey.currentContext is null, return");
        return;
      }
      final currentRoute =
          ModalRoute.of(rootNavigatorKey.currentContext!)?.settings.name;
      debugPrint(
          "currentRoute is $currentRoute  and step.routeName is ${step.routeName}");
      //We want to navigate only if we are not already on the desired route
      if (currentRoute != step.routeName) {
        rootNavigatorKey.currentState
            ?.pushReplacementNamed(step.routeName, arguments: step.arguments)
            .then(
              (value) =>
                  debugPrint('after navigation with rootNavigatorKey, $value'),
            );
      }
    } catch (e, st) {
      debugPrint('error on _showStep navigation : ${e.toString()} $st');
      _removeActiveIndex(index);
    }

    //Maybe our targeted widget is not mounted yet and required additional actions
    // Like opening a drawer or using a pagecontroller. We will check if this is needed.
    await _shouldPrepareNav(step, index, notifier);

    //Once navigation is done, we will restore our navigation observer
    // notifier.markOnboardingNavigationEnd();
    notifier.markShowing();

    final targetKey = await _waitForTargetKeyRegistration(step.targetId);
    debugPrint("Looking for key with id=${step.targetId}, got key=$targetKey");

    //Waiting for the widget context to be available
    if (targetKey == null) {
      debugPrint(
          "cannot find Key in Onboarding service, key is null, resetting index");
      _removeActiveIndex(index);
    }
    final widgetContext =
        await _tryGiveWidgetContextWhenAvalaible(key: targetKey);
    if (widgetContext == null) {
      debugPrint("cannot obtain widgetContext for id=${step.targetId}");
      _removeActiveIndex(index);
    }

    //We will finally use the WidgetContext to display the dialog

    try {
      debugPrint(
          'will try to showDialog in OnboardingService with widgetContext : $widgetContext');

      await OnboardingDialogClippedBackground(
        onboardingStep: step,
        onForward: () {
          //.pop() is called inside the onPressed function of the dialog,
          //in order to pop the right context. Do not add pop here, otherwise
          //the navigator will try to go back to a non-existent context
          //TODO Limiter les navigations entre les étapes en réintégrant pop. Actuellement pb de ctx

          // rootNavigatorKey.currentState!.pushReplacementNamed(step.routeName);
          // Navigator.of(widgetContext!).pop();
          WidgetsBinding.instance.addPostFrameCallback(
            (timeStamp) async {
              // notifier.makeStepLastShown(index);
              // _onboardingNotifier?.increment();
              await _next();
            },
          );
        },
        //TODO onBackward à définir
        onBackward: _complete,
      ).showOnBoardingDialog(widgetContext);
    } catch (e, st) {
      debugPrint(
          'Error when trying to showDialog during onboarding : ${e.toString()} $st');
    }
    //TODO refactor index shown
  }

  Future<void> _next() async {
    final notifier = _onboardingNotifier;
    if (notifier == null || notifier.currentIndex == null) return;
    notifier.makeStepShown(notifier.currentIndex!);
    if (notifier.currentIndex! < notifier.onBoardingsteps.length - 1) {
      //Making the onboarding status ready for next step
      notifier.markOnboardingNavigationEnd();
      notifier.increment();
    } else {
      await _complete();
    }
  }

  /// Ends the onboarding sequence by writing in local storage that onboarding has been shown.
  /// Resets the onboarding sequence to allow another run
  Future<void> _complete() async {
    debugPrint("_complete is running");
    //Important to prevent concurrency
    _onboardingNotifier?.markCompleting();
    await Provider.of<SharedPreferencesNotifier>(context, listen: false)
        .setHasSeenOnboardingTo(true);
    //setting status to completed, it is up to the OnboardingStateNotifier to
    //set the status to "ready" again.
    _onboardingNotifier?.markCompleted();
    _onboardingNotifier?.resetOnboarding();
  }

  ///Checks if further actions are needed after navigation to show the targeted widget.
  ///Performs then necessary actions to allow the targeted widget to be mounted inside the tree,
  ///through the prepareNav parameter of the provided OnboardingStep
  Future<void> _shouldPrepareNav(
      OnboardingStep step, int index, OnboardingStateNotifier notifier) async {
    //Maybe our targeted widget is not mounted yet and required additional actions
    // Like opening a drawer or using a pagecontroller
    // So we use the GlobalKey<State<StatefulWidget>> declared for the widget by onGenerateRoute to get
    //to get a valid context
    debugPrint("_shouldPrepareNav running");
    if (step.prepareNav == null) return;
    notifier.markPreparing();
    debugPrint("will attempt to get key for prepareNav");

    //Retrieves the GlobalKey<State<StatefulWidget> registered for this screen upon navigation.
    //This key will be used to obtain the State and performs actions like opening drawers, jumping in a page view, ...
    final key =
        OnboardingKeysService.instance.findScreenKeyWithId(step.routeName);
    if (key == null) {
      debugPrint(
          " findScreenKeyWithId could not obtain key for ${step.routeName}"
          " cannot run prepareNav and will return");
      notifier.makeStepInactive(index);
      return;
    }
    debugPrint("key for prepare nav is $key");

    //Waiting for the State of the screen
    final State<StatefulWidget>? state =
        await _waitForScreenState(key).then((value) {
      debugPrint("state for prepareNav is $value");
      return value;
    });
    debugPrint("will try to prepareNav");
    if (state == null) {
      debugPrint("state is null after _waitforScreenState, will return");
      notifier.makeStepInactive(index);
      return;
    }
    await step.prepareNav!(null, state);
  }

  Future<BuildContext?> _tryGiveWidgetContextWhenAvalaible({
    required GlobalKey? key,
    int timeout = 2000,
  }) async {
    if (key == null) return Future.value(null);

    final completer = Completer<BuildContext?>();
    final start = DateTime.now();

    void checkFuture() {
      final widgetContext = key.currentContext;
      if (widgetContext != null) {
        if (!completer.isCompleted) completer.complete(widgetContext);
        return;
      }
      final elapsed = DateTime.now().difference(start).inMilliseconds;

      //If we outreach our timer limit,
      //then we give up and return a null instead of context
      if (elapsed >= timeout) {
        if (!completer.isCompleted) completer.complete(null);
        return;
      }
      // if we still have time, we check again in the next frame
      WidgetsBinding.instance.addPostFrameCallback((_) => checkFuture());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => checkFuture());
    return completer.future;
  }

  //TODO refactoriser les waiters pour accepter un type T et une fonction, si pertinent
  Future<GlobalKey<State<StatefulWidget>>?> _waitForTargetKeyRegistration(
      String targetKeyId,
      {int timeoutMs = 2000}) async {
    final completer = Completer<GlobalKey?>();
    final start = DateTime.now();

    void check() {
      final key =
          OnboardingKeysService.instance.findTargetKeyWithId(targetKeyId);
      if (key != null) {
        completer.complete(key);
        return;
      }
      if (DateTime.now().difference(start).inMilliseconds > timeoutMs) {
        completer.complete(null);
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) => check());
    }

    check();
    return completer.future;
  }

  Future<State<StatefulWidget>?> _waitForScreenState(
      GlobalKey<State<StatefulWidget>> key,
      {int timeoutMs = 2000}) async {
    final completer = Completer<State<StatefulWidget>?>();
    final start = DateTime.now();

    void check() {
      final state = key.currentState;
      if (state != null) {
        completer.complete(state);
        return;
      }
      if (DateTime.now().difference(start).inMilliseconds > timeoutMs) {
        completer.complete(null);
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) => check());
    }

    check();
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

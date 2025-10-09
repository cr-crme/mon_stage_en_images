import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/models/database.dart';
import 'package:mon_stage_en_images/common/models/enum.dart';
import 'package:mon_stage_en_images/common/models/user.dart';
import 'package:mon_stage_en_images/main.dart';
import 'package:mon_stage_en_images/onboarding/application/onboarding_keys_service.dart';
import 'package:mon_stage_en_images/onboarding/application/onboarding_observer.dart';
import 'package:mon_stage_en_images/onboarding/application/shared_preferences_notifier.dart';
import 'package:mon_stage_en_images/onboarding/data/onboarding_steps_list.dart';
import 'package:mon_stage_en_images/onboarding/models/onboarding_step.dart';
import 'package:mon_stage_en_images/onboarding/widgets/onboarding_dialog_clipped_background.dart';
import 'package:provider/provider.dart';

///Main orchestrator for the Onboarding feature.  instead of a service or Notifier class,
/// it is defined as a SatefulWidget to access some properties of MaterialApp deeper in the tree,
///while allowing a single listening point throughout the app, rather than Consumer on every screen.
///See instanciation in main, inside a Stack Widget.
class OnboardingLayout extends StatefulWidget {
  const OnboardingLayout({
    super.key,
    required this.child,
    required this.onBoardingSteps,
  });

  final Widget child;
  final List<OnboardingStep> onBoardingSteps;

  @override
  State<OnboardingLayout> createState() => _OnboardingLayoutState();
}

class _OnboardingLayoutState extends State<OnboardingLayout> {
  bool _hasSeenOnboarding = false;
  bool _hasAlreadySeenTheIrrstPage = false;

  User? _currentUser;
  int? _currentIndex;

  OnboardingStep? get current {
    debugPrint(
        "When accessing current, _checkShowTutorial is ${_checkShowTutorial()} and _currentIndex is $_currentIndex");
    if (_checkShowTutorial() && _currentIndex != null) {
      return onboardingSteps[_currentIndex!];
    } else {
      return null;
    }
  }

  bool _checkShowTutorial() {
    final showTutorial = _currentUser != null &&
        _currentUser?.userType == UserType.teacher &&
        !_hasSeenOnboarding &&
        _hasAlreadySeenTheIrrstPage &&
        _currentUser!.termsAndServicesAccepted &&
        isValidScreenToShowTutorial.value;
    // debugPrint(
    //     "checkShowTutorial : _currentUser is $_currentUser | _hasSeenOnboarding is $_hasSeenOnboarding ");
    // debugPrint(
    //     "| _hasAlreadySeenTheIrrstPage is $_hasAlreadySeenTheIrrstPage | _currentUser!.termsAndServicesAccepted is ${_currentUser!.termsAndServicesAccepted}");
    // debugPrint("| isValidScreenToShowTutorial is $isValidScreenToShowTutorial");
    // debugPrint("checkShowTutorial : showTutorial is $showTutorial");
    return showTutorial;
  }

  void _increment() {
    if (_currentIndex == null) return;
    _currentIndex = _currentIndex! + 1;
    debugPrint("increment : _currentIndex is now $_currentIndex ");
  }

  void _decrement() {
    if (_currentIndex == null || _currentIndex! < 1) return;
    _currentIndex = _currentIndex! - 1;
    debugPrint("increment : _currentIndex is now $_currentIndex ");
  }

  void _resetIndex() {
    _currentIndex = onboardingSteps.isNotEmpty ? 0 : null;
  }

  Future<void> _next() async {
    if (_currentIndex == null) return;
    if (_currentIndex! < widget.onBoardingSteps.length - 1) {
      _increment();
      _tata();
    } else {
      _complete();
    }
  }

  Future<void> _previous() async {
    if (_currentIndex == null) return;
    if (_currentIndex! > 0) {
      _decrement();
      _tata();
    }
  }

  /// Ends the onboarding sequence by writing in local storage that onboarding has been shown.
  /// Resets the onboarding sequence to allow another run
  Future<void> _complete() async {
    debugPrint("_complete is running");
    await Provider.of<SharedPreferencesNotifier>(context, listen: false)
        .setHasSeenOnboardingTo(true);
    _resetIndex();
  }

  void _tata() async {
    await _showStep(_currentIndex!).whenComplete(() => setState(() {}));
  }

  @override
  void initState() {
    isValidScreenToShowTutorial.addListener(_tata);
    _resetIndex();
    super.initState();
  }

  Future<void> _getDependencies() async {
    debugPrint("_getDependencies running");
    _currentUser = Provider.of<Database>(context, listen: true).currentUser;
    final sharedPrefs =
        Provider.of<SharedPreferencesNotifier>(context, listen: true);

    _hasSeenOnboarding = await sharedPrefs.hasSeenOnboarding;
    _hasAlreadySeenTheIrrstPage = await sharedPrefs.hasAlreadySeenTheIrrstPage;
  }

// Using didChangeDependencies since initState doesn't allow for dependencies (context can't be accessed)
  @override
  void didChangeDependencies() async {
    debugPrint("didChangeDependencies running in _OnBoardingLayout");

    await _getDependencies();
    Future.delayed(Duration(milliseconds: 300));
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => _tata(),
    );
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    isValidScreenToShowTutorial.removeListener(_tata);
    super.dispose();
  }

  Future<void> _showStep(int index) async {
    debugPrint('_showStep running');

    //Checking if our step isn't null and if we should mark its index as inactive
    // final notifier = _onboardingNotifier!;
    final step = current;
    if (step == null) {
      debugPrint("_showStep will return because currentStep is null");
      return;
    }

    //Navigating to the OnboardingStep Widget's route.

    //Telling the observer through OnboardingStateNotifier that we should ignore
    // the next navigation events, as long as we are in the onboarding sequence.
    // notifier.markOnboardingNavigationStart();
    try {
      //Navigate to the screen registered in the onBoardingStep
      //with the rootNavigatorKey, since it is the only global context available
      if (rootNavigatorKey.currentContext == null) {
        debugPrint("rootNavigatorKey.currentContext is null, return");
        return;
      }
      final currentRoute =
          OnboardingNavigatorObserver.instance.currentRouteName;
      // ModalRoute.of(rootNavigatorKey.currentContext!)?.settings.name;

      debugPrint(
          "currentRoute is $currentRoute  and step.routeName is ${step.routeName}");
      //We want to navigate only if we are not already on the desired route
      if (currentRoute != step.routeName || _currentIndex == 0) {
        rootNavigatorKey.currentState
            ?.pushReplacementNamed(step.routeName, arguments: step.arguments)
            .then(
              (value) =>
                  debugPrint('after navigation with rootNavigatorKey, $value'),
            );
      }
    } catch (e, st) {
      debugPrint('error on _showStep navigation : ${e.toString()} $st');
      _resetIndex();
    }

    //Maybe our targeted widget is not mounted yet and required additional actions
    // Like opening a drawer or using a pagecontroller. We will check if this is needed.
    await _shouldPrepareNav(step, index);

    final targetKey = await _waitForTargetKeyRegistration(step.targetId);
    debugPrint("Looking for key with id=${step.targetId}, got key=$targetKey");

    //Waiting for the widget context to be available
    if (targetKey == null) {
      debugPrint(
          "cannot find Key in Onboarding service, key is null, resetting index");
      _resetIndex();
    }
    final widgetContext =
        await _tryGiveWidgetContextWhenAvalaible(key: targetKey);

    if (widgetContext == null) {
      debugPrint("cannot obtain widgetContext for id=${step.targetId}");
      _resetIndex();
    }
  }

  ///Checks if further actions are needed after navigation to show the targeted widget.
  ///Performs then necessary actions to allow the targeted widget to be mounted inside the tree,
  ///through the prepareNav parameter of the provided OnboardingStep
  Future<void> _shouldPrepareNav(
    OnboardingStep step,
    int index,
  ) async {
    //Maybe our targeted widget is not mounted yet and required additional actions
    // Like opening a drawer or using a pagecontroller
    // So we use the GlobalKey<State<StatefulWidget>> declared for the widget by onGenerateRoute to get
    //to get a valid context

    debugPrint("will attempt to get key for prepareNav");

    //Retrieves the GlobalKey<State<StatefulWidget> registered for this screen upon navigation.
    //This key will be used to obtain the State and performs actions like opening drawers, jumping in a page view, ...
    final key =
        OnboardingKeysService.instance.findScreenKeyWithId(step.routeName);
    if (key == null) {
      debugPrint(
          " findScreenKeyWithId could not obtain key for ${step.routeName}"
          " cannot run prepareNav and will return");
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
      return;
    }
    step.prepareNav == null
        ? await _tryGiveWidgetContextWhenAvalaible(key: key).then(
            (value) {
              debugPrint("value is $value");
              if (value != null && value.mounted) {
                step.resetScaffoldElements(value, state);
              }
            },
          )
        : await step.prepareNav!(null, state);
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
    debugPrint(
        "build : _currentUser is $_currentUser | _hasSeenOnboarding is $_hasSeenOnboarding ");
    debugPrint(
        "| _hasAlreadySeenTheIrrstPage is $_hasAlreadySeenTheIrrstPage | _currentUser!.termsAndServicesAccepted is ${_currentUser?.termsAndServicesAccepted}");
    debugPrint("| isValidScreenToShowTutorial is $isValidScreenToShowTutorial");
    debugPrint("build : showTutorial is ${_checkShowTutorial()}");

    return Stack(children: [
      widget.child,
      if (current != null && _currentIndex != null)
        OnboardingOverlayClippedBackground(
            complete: _complete,
            onboardingStep: current,
            onForward: () {
              _next();
            },
            onBackward: _currentIndex! > 0
                ? () {
                    _previous();
                  }
                : null),
    ]);
  }
}

import 'package:flutter/widgets.dart';
import 'package:mon_stage_en_images/common/models/user.dart';
import 'package:mon_stage_en_images/main.dart';
import 'package:mon_stage_en_images/onboarding/models/onboarding_step.dart';
import 'package:mon_stage_en_images/onboarding/widgets/onboarding_dialog_clipped_background.dart';

///Source of truth for the Onboarding status. Deals with other Notifier dependencies
///and sets flags for OnboardingObserver regarding navigation. Internally,
///this notifier manages the index of the OnboardingStep list provided as argument.
class OnboardingStateNotifier extends ChangeNotifier {
  OnboardingStateNotifier({
    required this.onBoardingsteps,
  });

  factory OnboardingStateNotifier.fromAuthAndPreferences({
    required List<OnboardingStep> onBoardingSteps,
    required User? currentUser,
    // required SharedPreferencesNotifier prefs,
    required Future<bool> hasSeenOnboarding,
    required Future<bool> hasAlreadySeenTheIrrstPage,
  }) {
    final notifier = OnboardingStateNotifier(onBoardingsteps: onBoardingSteps);
    notifier.updateDependencies(
        currentUser: currentUser,
        hasSeenOnboarding: hasSeenOnboarding,
        hasAlreadySeenTheIrrstPage: hasAlreadySeenTheIrrstPage);

    return notifier;
  }
  final List<OnboardingStep> onBoardingsteps;
  final Set<int> _stepsActive = {};
  bool _showTutorial = false;
  bool _isValidScreenToShowTutorial = false;
  bool _hasSeenOnboarding = false;
  bool _hasAlreadySeenTheIrrstPage = false;
  int? _lastIndexUsed;
  int? _currentIndex;
  User? _currentUser;

  bool get showTutorial => _showTutorial;
  int? get currentIndex => _currentIndex;
  OnboardingStep? get currentStep =>
      _currentIndex != null ? onBoardingsteps[_currentIndex!] : null;
  bool get _isNotValid => currentIndex == null || onBoardingsteps.isEmpty;

  bool isStepActive(int index) => _stepsActive.contains(index);
  void makeStepActive(int index) => _stepsActive.add(index);
  void makeStepInactive(int index) => _stepsActive.remove(index);
  bool stepHasBeenShown(int index) => _lastIndexUsed == index;
  void makeStepLastShown(int index) => _lastIndexUsed = index;

  Map<String, bool> showOnboardingConditions = {"": true};

  bool _isNavigatingForOnboarding = false;
  bool get isNavigatingForOnboarding => _isNavigatingForOnboarding;

  void markOnboardingNavigationStart() {
    _isNavigatingForOnboarding = true;
  }

  void markOnboardingNavigationEnd() {
    _isNavigatingForOnboarding = false;
  }

  void updateDependencies({
    required User? currentUser,
    required Future<bool> hasSeenOnboarding,
    required Future<bool> hasAlreadySeenTheIrrstPage,
  }) async {
    debugPrint('updateDependencies in OnboardingStateNotifier is running');

    _hasSeenOnboarding = await hasSeenOnboarding;
    _hasAlreadySeenTheIrrstPage = await hasAlreadySeenTheIrrstPage;
    _currentUser = currentUser;

    debugPrint("Update dependencies : "
        "completedHasSeenOnboarding is $_hasSeenOnboarding "
        "completedHasAlreadySeenTheIrrstPage is $_hasAlreadySeenTheIrrstPage "
        "termsAndServicesAccepted is ${currentUser?.termsAndServicesAccepted}");

    // final newShowTutorial = currentUser != null &&
    //     !_hasSeenOnboarding &&
    //     _hasAlreadySeenTheIrrstPage &&
    //     currentUser.termsAndServicesAccepted &&
    //     _isValidScreenToShowTutorial;
    // if (_showTutorial != newShowTutorial) {
    //   _showTutorial = newShowTutorial;

    // }
    debugPrint("ending UpdateDependencies : _showTutorial is $_showTutorial");
  }

  void checkShowTutorial() {
    final newShowTutorial = _currentUser != null &&
        !_hasSeenOnboarding &&
        _hasAlreadySeenTheIrrstPage &&
        _currentUser!.termsAndServicesAccepted &&
        _isValidScreenToShowTutorial;
    if (_showTutorial != newShowTutorial) {
      _showTutorial = newShowTutorial;
    }
    resetIndex();
    notifyListeners();
  }

  void setIsValidScreen(bool value) {
    _isValidScreenToShowTutorial = value;
    checkShowTutorial();
  }

  void increment() {
    debugPrint('increment running');
    if (_isNotValid) {
      debugPrint('isNotValide inside increment, return');
      return;
    }
    if (currentIndex! < onBoardingsteps.length - 1) {
      _currentIndex = currentIndex! + 1;
      debugPrint("_currentIndex is now $_currentIndex");
      notifyListeners();
    }
  }

  void decrement() {
    debugPrint('decrement running');
    if (_isNotValid) return;
    if (currentIndex! > 0) {
      _currentIndex = currentIndex! - 1;
      notifyListeners();
    }
  }

  go(BuildContext context, String routeName) {
    Navigator.of(context).pushReplacementNamed(routeName);
  }

  void notify() {
    notifyListeners();
  }

  set index(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void resetIndex() {
    _currentIndex = onBoardingsteps.isNotEmpty ? 0 : null;
    notifyListeners();
  }

  //TODO remove after check in future commit
  ///Discontinued method to be remove in future commit
  Future<BuildContext?> _matchDestination(
      BuildContext context, String routeName) async {
    debugPrint('will check if destinations match');
    if (!context.mounted || currentStep == null) return null;
    if (currentStep!.routeName != ModalRoute.of(context)?.settings.name) {
      // Navigator.of(context).pushReplacementNamed(routeName);
      final result = await rootNavigatorKey.currentState
          ?.pushNamed(
        routeName,
      )
          .then(
        (value) {
          return currentStep!.widgetKey?.currentContext;
        },
      );

      debugPrint('has travelled with _matchDestination');
      return result;
    }
    return null;
  }

  //TODO remove after check in future commit
  ///Discontinued method to be remove in future commit
  Future<void> runOnboarding(BuildContext context) async {
    debugPrint('runOnBoarding starts');

    if (!showTutorial || _isNotValid) {
      debugPrint('runOnboarding return, invalid');
      return;
    }
    if (_currentIndex == _lastIndexUsed) {
      debugPrint('_currentIndex and _lastIndexUsed are identical, return');
      return;
    }
    await _matchDestination(context, currentStep!.routeName);
    () => currentStep!.prepareNav;

    _lastIndexUsed = _currentIndex;
    debugPrint("_lastIndexUsed is $_lastIndexUsed");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final widgetContext = currentStep!.widgetKey?.currentContext;
      if (widgetContext == null) {
        debugPrint("widgetContext isn't mounted yet");
        return;
      }

      OnboardingDialogClippedBackground(
              onForward: increment,
              onBackward: decrement,
              onboardingStep: currentStep)
          .showOnBoardingDialog(widgetContext);
    }

        // if (ModalRoute.of(context) == null) {
        //   debugPrint("ModalRoute is null");
        //   return;
        // }

        );
  }
}

import 'package:flutter/widgets.dart';
import 'package:mon_stage_en_images/common/models/user.dart';
import 'package:mon_stage_en_images/onboarding/models/onboarding_step.dart';

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
  final Set<int> _stepsShown = {};
  OnboardingStatus _status = OnboardingStatus.dontShow;
  final bool _showTutorial = false;
  bool _isValidScreenToShowTutorial = false;
  bool _hasSeenOnboarding = false;
  bool _hasAlreadySeenTheIrrstPage = false;
  // int? _lastIndexUsed;
  int? _currentIndex;
  User? _currentUser;

  bool get showTutorial => _showTutorial;
  int? get currentIndex => _currentIndex;
  OnboardingStep? get currentStep =>
      _currentIndex != null ? onBoardingsteps[_currentIndex!] : null;
  bool get _isNotValid => currentIndex == null || onBoardingsteps.isEmpty;

  bool get isOnboardingShowing => _status == OnboardingStatus.showing;
  OnboardingStatus get status => _status;

  void _setStatus(OnboardingStatus newStatus) {
    if (_status == newStatus) return;
    _status = newStatus;
    notifyListeners();
  }

  bool isStepActive(int index) => _stepsActive.contains(index);
  void makeStepActive(int index) => _stepsActive.add(index);
  void makeStepInactive(int index) => _stepsActive.remove(index);
  bool stepHasBeenShown(int index) => _stepsShown.contains(index);
  void makeStepShown(int index) => _stepsShown.add(index);
  void emptyStepsActive() {
    _stepsActive.clear();
  }

  void emptyStepsShown() {
    _stepsShown.clear();
  }

  bool get isNavigatingForOnboarding =>
      _status == OnboardingStatus.preparing ||
      _status == OnboardingStatus.navigating;

  void markOnboardingNavigationStart() =>
      _setStatus(OnboardingStatus.navigating);

  void markOnboardingNavigationEnd() => _setStatus(OnboardingStatus.ready);

  void markPreparing() => _setStatus(OnboardingStatus.preparing);
  void markShowing() => _setStatus(OnboardingStatus.showing);
  void markCompleting() => _setStatus(OnboardingStatus.completing);
  void markCompleted() => _setStatus(OnboardingStatus.completed);

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

    checkShowTutorial();

    debugPrint("ending UpdateDependencies : _showTutorial is $_showTutorial");
  }

  void checkShowTutorial() {
    final showTutorial = _currentUser != null &&
        !_hasSeenOnboarding &&
        _hasAlreadySeenTheIrrstPage &&
        _currentUser!.termsAndServicesAccepted &&
        _isValidScreenToShowTutorial;
    if (!showTutorial) {
      _setStatus(OnboardingStatus.dontShow);
    } else {
      _setStatus(OnboardingStatus.ready);
    }
    resetIndex();
    emptyStepsActive();
    notifyListeners(); //à virer ???
  }

  void setIsValidScreen(bool value) {
    _isValidScreenToShowTutorial = value;
    checkShowTutorial();
  }

  void increment() {
    debugPrint('increment running');
    if (_isNotValid) {
      debugPrint('isNotValid inside increment, return');
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

  void notify() {
    notifyListeners();
  }

  set index(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void resetIndex() {
    _currentIndex = onBoardingsteps.isNotEmpty ? 0 : null;
    // _lastIndexUsed = null;
    notifyListeners();
  }

  void resetOnboarding() {
    resetIndex();
    emptyStepsActive();
    emptyStepsShown();
    notifyListeners();
  }
}

enum OnboardingStatus {
  dontShow,
  ready,
  showing,
  navigating,
  preparing,
  completing,
  completed,
}

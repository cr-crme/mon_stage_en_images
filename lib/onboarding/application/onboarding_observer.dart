import 'package:flutter/widgets.dart';
import 'package:mon_stage_en_images/onboarding/application/onboarding_state_notifier.dart';
import 'package:mon_stage_en_images/screens/login/check_version_screen.dart';
import 'package:mon_stage_en_images/screens/login/go_to_irsst_screen.dart';
import 'package:mon_stage_en_images/screens/login/login_screen.dart';
import 'package:mon_stage_en_images/screens/login/terms_and_services_screen.dart';

///This is a navigation observer for deciding whether the currentRoute
///is considered as a valid entry point for the onboarding sequence.
///It contains some redundancy checks for defaults route on purpose, which are also achieved by
///the method in onGeneratedInitialRoute parameter of MaterialApp in main.
///These checks should not be removed to prevent unflagged bugs during the login process
///if the onGenerateInitialRoute parameter were to be change later.

class OnboardingNavigatorObserver extends NavigatorObserver {
  OnboardingNavigatorObserver(this.onboarding);

  final OnboardingStateNotifier onboarding;

  ///This list contains every route that should be ignore by the navigation observer
  ///when it comes to decide whether or not the observed route is a valid entry point
  ///for the onboarding.
  final List<String?> routeExclusionList = [
    LoginScreen.routeName,
    TermsAndServicesScreen.routeName,
    GoToIrsstScreen.routeName,
    CheckVersionScreen.routeName,
    //Ignoring the first 'null' route when initializing the app
    //Another redundant check is present in _reactToNavigationEvent
    //To achieve similar goal
    null,
    //Default initialRoute excluded. OnGeneratedInitialRoute override in main
    // is a redudant protection but please keep this list entry if OnGeneratedInitialRoute
    //were to be changed later.
    "/"
  ];

  @override
  void didPush(Route route, Route? previousRoute) {
    debugPrint("didPush runs with new route : $route");
    _reactToNavigationEvent(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _reactToNavigationEvent(newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _reactToNavigationEvent(route);
    super.didPop(route, previousRoute);
  }

  _reactToNavigationEvent(Route? route) {
    //toggled by Onboarding service to stop listening navigation events when the onboarding is in progress.
    if (onboarding.isNavigatingForOnboarding) {
      debugPrint("_reactToNavigationEvent will ignore navigation event,"
          " onboarding.isNavigatingForOnboarding is ${onboarding.isNavigatingForOnboarding}");
      return;
    }

    debugPrint(
        "routeName in _reactToNavigationevent is ${route?.settings.name}");

    //Redundant check to ignore the default initial null route initialized by  the navigator.
    if (route?.settings.name == null) {
      debugPrint("Ignoring anonymous route push");
      return;
    }
    if (route is PageRoute) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          final routeContext = route.subtreeContext;

          if (routeContext != null
              // && !routeExclusionList.contains(route.settings.name)
              ) {
            final bool isValidScreen =
                !routeExclusionList.contains(route.settings.name);

            debugPrint("is ValidScreen is $isValidScreen");
            onboarding.setIsValidScreen(isValidScreen);
            // onboarding.runOnboarding(routeContext);
          }
        },
      );
    }
  }
}

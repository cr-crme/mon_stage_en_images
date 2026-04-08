import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logging/logging.dart';
import 'package:mon_stage_en_images/common/helpers/route_manager.dart';
import 'package:mon_stage_en_images/common/helpers/shared_preferences_manager.dart';
import 'package:mon_stage_en_images/common/models/enum.dart';
import 'package:mon_stage_en_images/common/models/themes.dart';
import 'package:mon_stage_en_images/common/providers/database.dart';
import 'package:mon_stage_en_images/common/providers/speecher.dart';
import 'package:mon_stage_en_images/default_onboarding_steps.dart';
import 'package:mon_stage_en_images/onboarding/onboarding.dart';
import 'package:mon_stage_en_images/screens/login/login_screen.dart';
import 'package:mon_stage_en_images/screens/login/wrong_version_screen.dart';
import 'package:provider/provider.dart';

import '/firebase_options.dart';

void main() async {
  // Set logging to INFO
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print(
        '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
  });

  // Initialization of the user database. If [useEmulator] is set to [true],
  // then a local database is created. To facilitate the filling of the database
  // one can create a user, login with it, then in the drawer, select the
  // 'Reinitialize the database' button.
  const useEmulator =
      bool.fromEnvironment('MSEI_USE_EMULATOR', defaultValue: false);
  await SharedPreferencesController.instance.initialize();
  final userDatabase =
      Database(onConnectionStateChanged: _onConnectionStateChanged);
  await userDatabase.initialize(
      useEmulator: useEmulator,
      currentPlatform: DefaultFirebaseOptions.currentPlatform);

  try {
    await Database.getRequiredSoftwareVersion();
  } catch (_) {
    // If previous session crashed, user may sometime remains logged in, preventing
    // from connecting to the database
    await userDatabase.logout();
  }

  await initializeDateFormatting('fr_FR', null);
  await RouteManager.instance.initialize();

  final onboardingController = OnboardingController(
    steps: OnboardingContexts.instance.onboardingSteps,
    onOnboardStarted: () async {
      await OnboardingContexts.instance.prepareForOnboarding();
    },
    onOnboardingCompleted: () async {
      await userDatabase.modifyUser(
          user: userDatabase.currentUser!,
          newInfo: userDatabase.currentUser!
              .copyWith(hasSeenTeacherOnboarding: true));
      await OnboardingContexts.instance.finilizeOnboarding();
    },
  );
  await OnboardingContexts.instance
      .initialize(controller: onboardingController);

  // Run the app
  runApp(MyApp(
      userDatabase: userDatabase, onboardingController: onboardingController));
}

class MyApp extends StatelessWidget {
  const MyApp(
      {super.key,
      required this.userDatabase,
      required this.onboardingController});

  final Database userDatabase;
  final OnboardingController onboardingController;

  @override
  Widget build(BuildContext context) {
    final speecher = Speecher();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => userDatabase),
        ChangeNotifierProvider(
            create: (context) => userDatabase.teacherAnswers),
        ChangeNotifierProvider(
            create: (context) => userDatabase.studentAnswers),
        ChangeNotifierProvider(create: (context) => userDatabase.questions),
        ChangeNotifierProvider(create: (context) => speecher),
      ],
      child: Consumer<Database>(builder: (context, database, static) {
        return MaterialApp(
          navigatorKey: RouteManager.instance.navigatorKey,
          debugShowCheckedModeBanner: false,
          initialRoute: RouteManager.instance.initialRoute,
          theme: database.userType == UserType.teacher
              ? teacherTheme()
              : studentTheme(),
          onGenerateInitialRoutes: (initialRoute) {
            return [
              MaterialPageRoute(
                settings: RouteSettings(name: initialRoute),
                builder: (context) =>
                    RouteManager.instance.builderForCurrentRoute(initialRoute),
              )
            ];
          },
          onGenerateRoute: (settings) {
            final String? routeName = settings.name;
            if (routeName == null) return null;

            if (routeName != LoginScreen.routeName &&
                routeName != WrongVersionScreen.routeName) {
              final user =
                  Provider.of<Database>(context, listen: false).currentUser;
              if (user == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  await RouteManager.instance.gotoLoginPage(context);
                  return;
                });
              }
            }

            return MaterialPageRoute(
                builder: (context) =>
                    RouteManager.instance.builderForCurrentRoute(routeName),
                settings: RouteSettings(
                    name: settings.name, arguments: settings.arguments));
          },
          builder: (context, child) {
            return OnboardingOverlay(
                controller: onboardingController, child: child!);
          },
        );
      }),
    );
  }
}

bool _isShowingNotConnectedDialog = false;
Future<void> _onConnectionStateChanged(bool isActive) async {
  // If we are not on any page, do nothing more
  if (RouteManager.instance.navigatorKey.currentContext == null) return;
  final context = RouteManager.instance.navigatorKey.currentContext!;

  // Show a blocking dialog if the connection is lost
  if (isActive) {
    if (_isShowingNotConnectedDialog) {
      _isShowingNotConnectedDialog = false;
      Navigator.of(context).pop();
    }
  } else {
    _isShowingNotConnectedDialog = true;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Connexion perdue'),
          content: const Text(
              'La connexion au serveur a été perdue. Veuillez vérifier votre connexion internet.'),
        );
      },
    );

    return;
  }
}

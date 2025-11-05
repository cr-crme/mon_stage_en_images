import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logging/logging.dart';
import 'package:mon_stage_en_images/common/models/database.dart';
import 'package:mon_stage_en_images/common/models/enum.dart';
import 'package:mon_stage_en_images/common/models/themes.dart';
import 'package:mon_stage_en_images/common/providers/speecher.dart';
import 'package:mon_stage_en_images/onboarding/application/onboarding_keys_service.dart';
import 'package:mon_stage_en_images/onboarding/application/onboarding_layout.dart';
import 'package:mon_stage_en_images/onboarding/application/onboarding_observer.dart';
import 'package:mon_stage_en_images/onboarding/application/shared_preferences_notifier.dart';
import 'package:mon_stage_en_images/onboarding/data/onboarding_steps_list.dart';
import 'package:mon_stage_en_images/screens/all_students/students_screen.dart';
import 'package:mon_stage_en_images/screens/login/check_version_screen.dart';
import 'package:mon_stage_en_images/screens/login/go_to_irsst_screen.dart';
import 'package:mon_stage_en_images/screens/login/login_screen.dart';
import 'package:mon_stage_en_images/screens/login/terms_and_services_screen.dart';
import 'package:mon_stage_en_images/screens/q_and_a/q_and_a_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/firebase_options.dart';

const String softwareVersion = '1.1.1';
final _logger = Logger('main');
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
ValueNotifier<bool> isValidScreenToShowTutorial = ValueNotifier<bool>(false);
const showDebugOverlay = false;

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
  final userDatabase = Database();
  await userDatabase.initialize(
      useEmulator: useEmulator,
      currentPlatform: DefaultFirebaseOptions.currentPlatform);

  await initializeDateFormatting('fr_FR', null);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // Run the app
  runApp(MyApp(
    userDatabase: userDatabase,
    prefs: prefs,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.userDatabase,
    required this.prefs,
  });

  final Database userDatabase;
  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    final sharedPreferencesNotifier = SharedPreferencesNotifier(prefs: prefs);
    final speecher = Speecher();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => userDatabase),
        ChangeNotifierProvider(create: (context) => userDatabase.answers),
        ChangeNotifierProvider(create: (context) => userDatabase.questions),
        ChangeNotifierProvider(create: (context) => speecher),
        ChangeNotifierProvider(create: (context) => sharedPreferencesNotifier)
      ],
      child: Consumer<Database>(builder: (context, database, static) {
        return MaterialApp(
          navigatorKey: rootNavigatorKey,
          debugShowCheckedModeBanner: false,
          initialRoute: CheckVersionScreen.routeName,

          theme: database.currentUser != null &&
                  database.currentUser!.userType == UserType.teacher
              ? teacherTheme()
              : studentTheme(),
          onGenerateInitialRoutes: (initialRoute) {
            _logger.finest(
                'initial route in onGenerateInitial Routes is $initialRoute');
            final key = GlobalKey<State<StatefulWidget>>();
            final String id = initialRoute;

            OnboardingKeysService.instance.addScreenKey(id, key);
            return [
              MaterialPageRoute(
                settings: RouteSettings(name: initialRoute),
                builder: (context) {
                  return getWidgetFromRouteName(initialRoute, key);
                },
              )
            ];
          },
          onGenerateRoute: (settings) {
            _logger.finest(
                'onGenerateRoute runs with settings.name : ${settings.name}');
            final String? routeName = settings.name;
            if (routeName == null) return null;
            final key = GlobalKey<State<StatefulWidget>>();
            final String id = routeName;

            OnboardingKeysService.instance.addScreenKey(id, key);
            final pageRoute = MaterialPageRoute(
                builder: (_) => getWidgetFromRouteName(routeName, key),
                settings: RouteSettings(
                    name: settings.name, arguments: settings.arguments));
            _logger.finest(
                'onGenerateRoute : pageRoute settings name is ${pageRoute.settings.name}');
            return pageRoute;
          },
          navigatorObservers: [OnboardingNavigatorObserver.instance],
          // routes: {
          //   CheckVersionScreen.routeName: (context) =>
          //       const CheckVersionScreen(),
          //   LoginScreen.routeName: (context) => const LoginScreen(),
          //   TermsAndServicesScreen.routeName: (context) =>
          //       const TermsAndServicesScreen(),
          //   GoToIrsstScreen.routeName: (context) => const GoToIrsstScreen(),
          //   StudentsScreen.routeName: (context) => const StudentsScreen(),
          //   QAndAScreen.routeName: (context) => const QAndAScreen(),
          // },
          builder: (context, child) {
            final shared = Provider.of<SharedPreferencesNotifier>(context);
            return OnboardingLayout(
              onBoardingSteps: onboardingSteps,
              child: Stack(alignment: Alignment.bottomCenter, children: [
                child!,
                if (showDebugOverlay)
                  Positioned(
                    bottom: 150,
                    child: Material(
                      child: FutureBuilder<bool>(
                          key: ValueKey('Debug onboarding shared pref switch'),
                          future: shared.hasSeenOnboarding,
                          builder: (ctx, value) => value.hasData
                              ? SizedBox(
                                  width: 250,
                                  child: Card(
                                    color: Theme.of(context)
                                        .secondaryHeaderColor
                                        .withAlpha(150),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(value.data!
                                            ? 'Onboarding vu'
                                            : 'Onboarding non vu'),
                                        Switch(
                                          value: value.data!,
                                          onChanged: (_) async {
                                            await shared.setHasSeenOnboardingTo(
                                                !value.data!);
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              : CircularProgressIndicator()),
                    ),
                  )
              ]),
            );
          },
        );
      }),
    );
  }
}

Widget getWidgetFromRouteName(
    String routeName, GlobalKey<State<StatefulWidget>> key) {
  switch (routeName) {
    case CheckVersionScreen.routeName:
      return CheckVersionScreen(key: key);
    case LoginScreen.routeName:
      return LoginScreen(key: key);
    case TermsAndServicesScreen.routeName:
      return TermsAndServicesScreen(key: key);
    case GoToIrsstScreen.routeName:
      return GoToIrsstScreen(key: key);
    case StudentsScreen.routeName:
      return StudentsScreen(key: key);
    case QAndAScreen.routeName:
      return QAndAScreen(key: key);
    default:
      return SizedBox.shrink(key: key);
  }
}

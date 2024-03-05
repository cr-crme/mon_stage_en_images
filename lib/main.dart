import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/models/database.dart';
import 'package:mon_stage_en_images/common/models/enum.dart';
import 'package:mon_stage_en_images/common/models/themes.dart';
import 'package:mon_stage_en_images/common/providers/speecher.dart';
import 'package:mon_stage_en_images/screens/all_students/students_screen.dart';
import 'package:mon_stage_en_images/screens/login/check_version_screen.dart';
import 'package:mon_stage_en_images/screens/login/go_to_irsst_screen.dart';
import 'package:mon_stage_en_images/screens/login/login_screen.dart';
import 'package:mon_stage_en_images/screens/q_and_a/q_and_a_screen.dart';
import 'package:provider/provider.dart';

import '/firebase_options.dart';

const String softwareVersion = '1.0.0';

void main() async {
  // Initialization of the user database. If [useEmulator] is set to [true],
  // then a local database is created. To facilitate the filling of the database
  // one can create a user, login with it, then in the drawer, select the
  // 'Reinitialize the database' button.

  const useEmulator = true;
  final userDatabase = Database();
  await userDatabase.initialize(
      useEmulator: useEmulator,
      currentPlatform: DefaultFirebaseOptions.currentPlatform);

  // Run the app
  runApp(MyApp(userDatabase: userDatabase));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.userDatabase,
  });

  final Database userDatabase;

  @override
  Widget build(BuildContext context) {
    final speecher = Speecher();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => userDatabase),
        ChangeNotifierProvider(create: (context) => userDatabase.answers),
        ChangeNotifierProvider(create: (context) => userDatabase.questions),
        ChangeNotifierProvider(create: (context) => speecher),
      ],
      child: Consumer<Database>(builder: (context, database, static) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: CheckVersionScreen.routeName,
          theme: database.currentUser != null &&
                  database.currentUser!.userType == UserType.teacher
              ? teacherTheme()
              : studentTheme(),
          routes: {
            CheckVersionScreen.routeName: (context) =>
                const CheckVersionScreen(),
            LoginScreen.routeName: (context) => const LoginScreen(),
            GoToIrsstScreen.routeName: (context) => const GoToIrsstScreen(),
            StudentsScreen.routeName: (context) => const StudentsScreen(),
            QAndAScreen.routeName: (context) => const QAndAScreen(),
          },
        );
      }),
    );
  }
}

import 'package:defi_photo/common/models/database.dart';
import 'package:defi_photo/common/models/enum.dart';
import 'package:defi_photo/common/models/themes.dart';
import 'package:defi_photo/common/providers/all_questions.dart';
import 'package:defi_photo/common/providers/all_students.dart';
import 'package:defi_photo/common/providers/speecher.dart';
import 'package:defi_photo/screens/all_students/students_screen.dart';
import 'package:defi_photo/screens/login/login_screen.dart';
import 'package:defi_photo/screens/q_and_a/q_and_a_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/firebase_options.dart';

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
    final students = AllStudents();
    final questions = AllQuestions();
    final speecher = Speecher();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => userDatabase),
        ChangeNotifierProvider(create: (context) => students),
        ChangeNotifierProvider(create: (context) => questions),
        ChangeNotifierProvider(create: (context) => speecher),
      ],
      child: Consumer<Database>(builder: (context, database, static) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: LoginScreen.routeName,
          theme: database.currentUser != null &&
                  database.currentUser!.userType == UserType.teacher
              ? teacherTheme()
              : studentTheme(),
          routes: {
            LoginScreen.routeName: (context) => const LoginScreen(),
            StudentsScreen.routeName: (context) => const StudentsScreen(),
            QAndAScreen.routeName: (context) => const QAndAScreen(),
          },
        );
      }),
    );
  }
}

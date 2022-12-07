import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/user_database_abstract.dart';
import '/common/models/user_database_firebase.dart';
import '/common/providers/all_questions.dart';
import '/common/providers/all_students.dart';
import '/common/providers/login_information.dart';
import '/common/providers/speecher.dart';
import '/common/widgets/database_clearer.dart';
import '/screens/all_students/students_screen.dart';
import '/screens/login/login_screen.dart';
import '/screens/q_and_a/q_and_a_screen.dart';

void main() async {
  // Initialization of the user database. If [useEmulator] is set to [true],
  // then a local database is created. To facilitate the filling of the database
  // one can create a user, login with it, then in the drawer, select the
  // 'Reinitialize the database' button.
  const useEmulator = true;
  final userDatabase = UserDatabaseFirebase();
  await userDatabase.initialize(useEmulator: useEmulator);

  const databaseClearerOptions = DatabaseClearerOptions(
      allowClearing: useEmulator, populateWithDummyData: false);

  // Run the app!
  runApp(MyApp(
      userDatabase: userDatabase,
      databaseClearerOptions: databaseClearerOptions));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.userDatabase,
    required this.databaseClearerOptions,
  });

  final UserDataBaseAbstract userDatabase;
  final DatabaseClearerOptions databaseClearerOptions;

  @override
  Widget build(BuildContext context) {
    final loginInformation = LoginInformation(userDatabase: userDatabase);
    final students = AllStudents();
    final questions = AllQuestions();
    final speecher = Speecher();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => loginInformation),
        ChangeNotifierProvider(create: (context) => students),
        ChangeNotifierProvider(create: (context) => questions),
        ChangeNotifierProvider(create: (context) => speecher),
      ],
      child: Consumer<LoginInformation>(builder: (context, theme, child) {
        return MaterialApp(
          theme: theme.themeData,
          initialRoute: LoginScreen.routeName,
          routes: {
            LoginScreen.routeName: (context) => const LoginScreen(),
            StudentsScreen.routeName: (context) => StudentsScreen(
                  databaseClearerOptions: databaseClearerOptions,
                ),
            QAndAScreen.routeName: (context) => const QAndAScreen(),
          },
        );
      }),
    );
  }
}

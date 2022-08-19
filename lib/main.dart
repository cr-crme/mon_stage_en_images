import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './dummy_data.dart';
import './common/providers/all_questions.dart';
import './common/providers/all_students.dart';
import './common/providers/login_information.dart';
import './common/providers/speecher.dart';
import 'common/models/user_database_abstract.dart';
import 'common/models/user_database_firebase.dart';
import './screens/all_students/students_screen.dart';
import './screens/login/login_screen.dart';
import './screens/q_and_a/q_and_a_screen.dart';

void main() async {
  final userDatabase = UserDatabaseFirebase();
  await userDatabase.initialize(useEmulator: true);
  runApp(MyApp(userDatabase: userDatabase));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.userDatabase}) : super(key: key);

  final UserDataBaseAbstract userDatabase;

  @override
  Widget build(BuildContext context) {
    final loginInformation = LoginInformation(userDatabase: userDatabase);
    final students = AllStudents();
    final questions = AllQuestions();
    final speecher = Speecher();
    prepareDummyData(students, questions);

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
            StudentsScreen.routeName: (context) => const StudentsScreen(),
            QAndAScreen.routeName: (context) => const QAndAScreen(),
          },
        );
      }),
    );
  }
}

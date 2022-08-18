import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './dummy_data.dart';
import './common/providers/all_questions.dart';
import './common/providers/all_students.dart';
import './common/providers/all_users.dart';
import './common/providers/login_information.dart';
import './common/providers/speecher.dart';
import './common/models/database_abstract.dart';
import './common/models/database_firebase.dart';
import './screens/all_students/students_screen.dart';
import './screens/login/login_screen.dart';
import './screens/q_and_a/q_and_a_screen.dart';

void main() async {
  final database = DatabaseFirebase();
  await database.initialize();
  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.database}) : super(key: key);

  final DataBaseAbstract database;

  @override
  Widget build(BuildContext context) {
    final loginInformation = LoginInformation(database: database);
    final students = AllStudents();
    final genericInformation = AllUsers(database: database);
    final questions = AllQuestions();
    final speecher = Speecher();
    prepareDummyData(students, questions);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => loginInformation),
        ChangeNotifierProvider(create: (context) => students),
        ChangeNotifierProvider(create: (context) => genericInformation),
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

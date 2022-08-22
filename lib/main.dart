import 'package:defi_photo/common/models/section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './common/models/enum.dart';
import './common/models/question.dart';
import './common/models/user_database_abstract.dart';
import './common/models/user_database_firebase.dart';
import './common/providers/all_questions.dart';
import './common/providers/all_students.dart';
import './common/providers/login_information.dart';
import './common/providers/speecher.dart';
import './screens/all_students/students_screen.dart';
import './screens/login/login_screen.dart';
import './screens/q_and_a/q_and_a_screen.dart';

void main() async {
  // These are the default questions when creating a new teacher
  final defaultQuestions = [
    Question('Montre moi la couleur du tapis',
        section: 0, defaultTarget: Target.all),
    Question('Qui est le responsable des RH',
        section: 5, defaultTarget: Target.all),
  ];

  final userDatabase = UserDatabaseFirebase();
  await userDatabase.initialize(useEmulator: true);
  runApp(MyApp(userDatabase: userDatabase, defaultQuestions: defaultQuestions));
}

class MyApp extends StatelessWidget {
  const MyApp(
      {Key? key, required this.userDatabase, required this.defaultQuestions})
      : super(key: key);

  final UserDataBaseAbstract userDatabase;
  final List<Question> defaultQuestions;

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
            LoginScreen.routeName: (context) =>
                LoginScreen(defaultQuestions: defaultQuestions),
            StudentsScreen.routeName: (context) =>
                const StudentsScreen(withPopulateWithFalseDataButton: true),
            QAndAScreen.routeName: (context) => const QAndAScreen(),
          },
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './dummy_data.dart';
import './common/providers/all_questions.dart';
import './common/providers/user.dart';
import 'common/providers/all_students.dart';
import './common/widgets/my_theme_data.dart';
import './screens/student_info/student_screen.dart';
import './screens/all_students/students_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final user = User(name: 'Pariterre');
    final students = AllStudents();
    final questions = AllQuestions();
    prepareDummyData(students, questions);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => user),
        ChangeNotifierProvider(create: (context) => students),
        ChangeNotifierProvider(create: (context) => questions),
      ],
      child: MaterialApp(
        theme: myThemeData(),
        initialRoute: StudentsScreen.routeName,
        routes: {
          StudentsScreen.routeName: (context) => const StudentsScreen(),
          StudentScreen.routeName: (context) => const StudentScreen(),
        },
      ),
    );
  }
}

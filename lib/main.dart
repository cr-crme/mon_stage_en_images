import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './models/student.dart';
import './providers/students.dart';
import './screens/students_screen.dart';
import './screens/student_main_screen.dart';
import './models/my_theme_data.dart';

void prepareDummyData(Students students) {
  students
      .add(Student(firstName: 'Benjamin', lastName: 'Michaud', progression: 5));
  students
      .add(Student(firstName: 'Aurélie', lastName: 'Tondoux', progression: 20));
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final students = Students();
    prepareDummyData(students);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => students),
      ],
      child: MaterialApp(
        theme: myThemeData(),
        initialRoute: StudentsScreen.routeName,
        routes: {
          StudentsScreen.routeName: (context) => const StudentsScreen(),
          StudentMainScreen.routeName: (context) => const StudentMainScreen(),
        },
      ),
    );
  }
}

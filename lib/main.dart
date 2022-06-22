import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './models/company.dart';
import './models/my_theme_data.dart';
import './models/question.dart';
import './models/student.dart';
import './providers/all_question_lists.dart';
import './providers/students.dart';
import './screens/section_screen.dart';
import './screens/student_main_screen.dart';
import './screens/students_screen.dart';

void prepareDummyData(Students students, AllQuestionList questions) {
  questions[0].add(Question('Qui es-tu?'));
  questions[1].add(Question('Qui es-tu?'));
  questions[2].add(Question('Qui es-tu?'));
  questions[3].add(Question('Qui es-tu?'));
  questions[4].add(Question('Qui es-tu?'));
  questions[5].add(Question('Qui es-tu?'));
  questions[5].add(Question('Qui es-tu?'));
  questions[5].add(Question('Qui es-tu?'));

  final company = Company(name: 'Ici');

  students.add(
      Student(firstName: 'Benjamin', lastName: 'Michaud', company: company));

  students.add(Student(firstName: 'Aurélie', lastName: 'Tondoux'));
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final students = Students();
    final questions = AllQuestionList();
    prepareDummyData(students, questions);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => students),
        ChangeNotifierProvider(create: (context) => questions),
      ],
      child: MaterialApp(
        theme: myThemeData(),
        initialRoute: StudentsScreen.routeName,
        routes: {
          StudentsScreen.routeName: (context) => const StudentsScreen(),
          StudentMainScreen.routeName: (context) => const StudentMainScreen(),
          SectionScreen.routeName: (context) => const SectionScreen(),
        },
      ),
    );
  }
}

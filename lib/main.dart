import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/students.dart';
import './screens/students_screen.dart';
import './screens/student_main_screen.dart';
import './models/my_theme_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Students()),
      ],
      child: MaterialApp(
        theme: myThemeData(),
        initialRoute: StudentScreen.routeName,
        routes: {
          StudentScreen.routeName: (context) => const StudentScreen(),
          StudentMainScreen.routeName: (context) => const StudentMainScreen(),
        },
      ),
    );
  }
}

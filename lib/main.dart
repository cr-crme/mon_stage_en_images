import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './dummy_data.dart';
import './common/providers/all_questions.dart';
import './common/providers/all_students.dart';
import './common/providers/login_information.dart';
import './common/providers/speecher.dart';
import './screens/all_students/students_screen.dart';
import './screens/login/login_screen.dart';
import './screens/q_and_a/q_and_a_screen.dart';
import './firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Connect Firebase to local emulators
  // When in production set android:usesCleartextTraffic to false in AndroidManifest.xml
  assert(() {
    FirebaseAuth.instance.useAuthEmulator("localhost", 9099);
    FirebaseDatabase.instance.useDatabaseEmulator(
        !kIsWeb && Platform.isAndroid ? "10.0.2.2" : "localhost", 9000);
    FirebaseStorage.instance.useStorageEmulator("localhost", 9199);
    return true;
  }());
  // FirebaseAuth.instance.signInAnonymously();
  final authenticator = FirebaseAuth.instance;
  // authenticator.createUserWithEmailAndPassword(
  //     email: 'coucou@coucou.com', password: '123456');
  authenticator.signInWithEmailAndPassword(
      email: 'coucou@coucou.com', password: '123456');

  final login = LoginInformation();
  const teacherName = 'Moi';
  runApp(const MyApp(
    teacherName: teacherName,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.teacherName}) : super(key: key);

  final String teacherName;
  //final LoginInformation loginInformation;

  @override
  Widget build(BuildContext context) {
    final loginInformation = LoginInformation();
    final students = AllStudents(teacherName: teacherName);
    final questions = AllQuestions(teacherName: teacherName);
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

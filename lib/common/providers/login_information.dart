import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './all_questions.dart';
import './all_students.dart';
import '../models/user_database_abstract.dart';
import '../models/enum.dart';
import '../models/themes.dart';
import '../models/user.dart';

class LoginInformation with ChangeNotifier {
  LoginInformation({required this.userDatabase});

  final UserDataBaseAbstract userDatabase;
  LoginType loginType = LoginType.none;
  User? user;

  Future<LoginStatus> login(
    BuildContext context, {
    required String email,
    required String password,
    required Function(String email) newUserUiCallback,
  }) async {
    final students = Provider.of<AllStudents>(context, listen: false);
    final questions = Provider.of<AllQuestions>(context, listen: false);
    final status = await userDatabase.login(email, password);
    if (status != LoginStatus.success) return status;

    user = await userDatabase.getUser(email);
    if (user == null) {
      user = await newUserUiCallback(email);
      if (user == null) return LoginStatus.cancelled;
      await addUserToDatabase(
          newUser: user!, password: password, override: true);
    }
    _registerUser(students, questions);
    return LoginStatus.success;
  }

  void _registerUser(AllStudents students, AllQuestions questions) {
    _selectLoginType(user!.isStudent ? LoginType.student : LoginType.teacher);
    _notifyAnotherProvider(students);
    _notifyAnotherProvider(questions);
  }

  void _selectLoginType(LoginType theme) {
    loginType = theme;
    notifyListeners();
  }

  void _notifyAnotherProvider(provider) {
    if (user!.isStudent) {
      provider.pathToAvailableDataIds = user!.addedBy;
    } else {
      provider.pathToAvailableDataIds = user!.id;
    }
  }

  ThemeData get themeData {
    switch (loginType) {
      case LoginType.student:
        return studentTheme();
      case LoginType.teacher:
        return teacherTheme();
      default:
        return studentTheme();
    }
  }

  Future<LoginStatus> addUserToDatabase({
    required User newUser,
    required String password,
    required bool override,
  }) async {
    return userDatabase.send(
        user: newUser, password: password, override: override);
  }
}

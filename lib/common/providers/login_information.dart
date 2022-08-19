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
    required Future<String> Function() changePasswordCallback,
  }) async {
    final students = Provider.of<AllStudents>(context, listen: false);
    final questions = Provider.of<AllQuestions>(context, listen: false);
    var status = await userDatabase.login(email, password);
    if (status != LoginStatus.success) return status;

    user = await userDatabase.getUser(email);
    if (user == null) {
      user = await newUserUiCallback(email);
      if (user == null) return LoginStatus.cancelled;
      status = await addUserToDatabase(newUser: user!, password: password);
      if (status != LoginStatus.success) return status;
    }

    if (user!.shouldChangePassword) {
      String newPassword = await changePasswordCallback();
      status = await userDatabase.updatePassword(user!, newPassword);
      if (status != LoginStatus.success) return status;
    }

    _finalizeLogin(students, questions);
    return LoginStatus.success;
  }

  void _finalizeLogin(AllStudents students, AllQuestions questions) {
    loginType = user!.isStudent ? LoginType.student : LoginType.teacher;
    _notifyProvider(students);
    _notifyProvider(questions);
    notifyListeners();
  }

  void _notifyProvider(provider) {
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
  }) async {
    return userDatabase.send(user: newUser, password: password);
  }
}

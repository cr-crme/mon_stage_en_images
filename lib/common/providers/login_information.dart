import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './all_questions.dart';
import './all_students.dart';
import '../models/enum.dart';
import '../models/themes.dart';
import '../models/user.dart';

class LoginInformation with ChangeNotifier {
  LoginInformation({required this.loginCallback});

  LoginType loginType = LoginType.none;
  User? user;
  final Future<LoginStatus> Function(User, String password) loginCallback;

  Future<LoginStatus> login(
    BuildContext context, {
    required User user,
    required String password,
    required LoginType loginType,
  }) async {
    final students = Provider.of<AllStudents>(context, listen: false);
    final questions = Provider.of<AllQuestions>(context, listen: false);

    final status = await loginCallback(user, password);
    if (status != LoginStatus.connected) return status;

    this.user = user;
    _selectLoginType(loginType);
    _notifyAnotherProvider(students);
    _notifyAnotherProvider(questions);
    return status;
  }

  void _selectLoginType(LoginType theme) {
    loginType = theme;
    notifyListeners();
  }

  void _notifyAnotherProvider(provider) {
    provider.pathToAvailableDataIds = user!.name;
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
}

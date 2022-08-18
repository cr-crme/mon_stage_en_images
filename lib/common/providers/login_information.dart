import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './all_questions.dart';
import './all_students.dart';
import '../models/database_abstract.dart';
import '../models/enum.dart';
import '../models/themes.dart';
import '../models/user.dart';

class LoginInformation with ChangeNotifier {
  LoginInformation({required this.database});

  LoginType loginType = LoginType.none;
  User? user;
  final DataBaseAbstract database;

  Future<LoginStatus> login(
    BuildContext context, {
    required String email,
    required String password,
    required LoginType loginType,
  }) async {
    final students = Provider.of<AllStudents>(context, listen: false);
    final questions = Provider.of<AllQuestions>(context, listen: false);

    final status = await database.login(email, password);
    if (status != LoginStatus.connected) return status;

    // TODO: Read the information from the server
    user = User(firstName: '', lastName: '', email: email, addedBy: '');
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
    provider.pathToAvailableDataIds = user!;
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

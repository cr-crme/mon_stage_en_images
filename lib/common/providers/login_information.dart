import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './all_questions.dart';
import './all_students.dart';
import '../misc/database_helper.dart';
import '../models/database_abstract.dart';
import '../models/enum.dart';
import '../models/themes.dart';
import '../models/user.dart';

class LoginInformation with ChangeNotifier {
  LoginInformation({required this.database});

  LoginType loginType = LoginType.none;
  User? user;

  Future<LoginStatus> login(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    final students = Provider.of<AllStudents>(context, listen: false);
    final questions = Provider.of<AllQuestions>(context, listen: false);

    final status = await database.login(email, password);
    if (status != LoginStatus.signedIn) return status;

    user = await getUserFromDatabase(email);
    _selectLoginType(user!.isStudent ? LoginType.student : LoginType.teacher);
    _notifyAnotherProvider(students);
    _notifyAnotherProvider(questions);
    return status;
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

  final DataBaseAbstract database;
  final String pathToUsers = 'users';
  void addUserToDatabase(User userInformation) {
    database.send(pathToUsers, userInformation);
  }

  Future<User> getUserFromDatabase(String email) async {
    final id = emailToPath(email);
    return database.getUser('$pathToUsers/$id');
  }
}

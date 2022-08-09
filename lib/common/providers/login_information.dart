import 'package:flutter/material.dart';

import '../models/enum.dart';
import '../models/themes.dart';
import '../models/user.dart';

class LoginInformation with ChangeNotifier {
  LoginType loginType = LoginType.none;
  User? user;

  void login(String username, LoginType type) {
    user = User(name: username);
    _selectLoginType(type);
  }

  void _selectLoginType(LoginType theme) {
    loginType = theme;
    notifyListeners();
  }

  ThemeData get themeData {
    switch (loginType) {
      case LoginType.student:
        return studentTheme();
      case LoginType.teacher:
        return teacherTheme();
      default:
        return teacherTheme();
    }
  }
}

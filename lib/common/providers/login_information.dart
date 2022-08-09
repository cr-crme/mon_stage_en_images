import 'package:flutter/material.dart';

import '../models/enum.dart';
import '../models/themes.dart';

class LoginInformation with ChangeNotifier {
  LoginType loginType = LoginType.none;

  void selectLoginType(LoginType theme) {
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

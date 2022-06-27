import 'package:flutter/material.dart';

import '../models/enum.dart';
import '../models/exceptions.dart';
import '../models/themes.dart';

class LoginInformation with ChangeNotifier {
  LoginType loginType = LoginType.teacher;

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
        throw const NotImplemented('This theme is not implemented yet');
    }
  }
}

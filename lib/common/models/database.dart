import 'package:ezlogin/ezlogin.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

import 'user.dart';

export 'package:ezlogin/ezlogin.dart';

class Database extends EzloginFirebase with ChangeNotifier {
  ///
  /// This is an internal structure to quickly access the current
  /// user information. These may therefore be out of sync with the database
  ///
  User? _currentUser;

  @override
  User? get currentUser => _currentUser;

  @override
  Future<EzloginStatus> login({
    required String username,
    required String password,
    Future<EzloginUser?> Function()? getNewUserInfo,
    Future<String?> Function()? getNewPassword,
  }) async {
    final status = await super.login(
        username: username,
        password: password,
        getNewUserInfo: getNewUserInfo,
        getNewPassword: getNewPassword);
    _currentUser = await user(username);
    notifyListeners();
    return status;
  }

  @override
  Future<EzloginStatus> logout() {
    _currentUser = null;
    notifyListeners();
    return super.logout();
  }

  @override
  Future<EzloginStatus> modifyUser(
      {required EzloginUser user, required EzloginUser newInfo}) async {
    final status = await super.modifyUser(user: user, newInfo: newInfo);
    if (user.email == currentUser?.email) {
      _currentUser = await this.user(user.email);
      notifyListeners();
    }
    return status;
  }

  @override
  Future<User?> user(String username) async {
    final id = emailToPath(username);
    final data = await FirebaseDatabase.instance.ref('$usersPath/$id').get();
    return data.value == null ? null : User.fromSerialized(data.value);
  }
}

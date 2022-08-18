import 'package:defi_photo/common/models/database_abstract.dart';
import 'package:flutter/cupertino.dart';

import '../models/user.dart';

class AllUsers with ChangeNotifier {
  AllUsers({required this.database});

  final DataBaseAbstract database;
  final String pathToGenericInformation = 'users';

  void addUser(User userInformation) {
    database.send(pathToGenericInformation, userInformation);
  }
}

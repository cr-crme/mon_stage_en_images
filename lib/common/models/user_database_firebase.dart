import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import './user_database_abstract.dart';
import './enum.dart';
import './user.dart' as local_user;
import '../misc/database_helper.dart';
import '../../firebase_options.dart';

class UserDatabaseFirebase extends UserDataBaseAbstract {
  @override
  Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    // Connect Firebase to local emulators
    // IMPORTANT: when in production set android:usesCleartextTraffic to 'false'
    // in AndroidManifest.xml, to enforce 'https' connexions.
    assert(() {
      FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      FirebaseDatabase.instance.useDatabaseEmulator(
          !kIsWeb && Platform.isAndroid ? '10.0.2.2' : 'localhost', 9000);
      FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
      return true;
    }());
  }

  @override
  Future<LoginStatus> login(String email, String password) async {
    final authenticator = FirebaseAuth.instance;
    try {
      await authenticator.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      if ((e as FirebaseAuthException).code == 'user-not-found') {
        return LoginStatus.wrongUsername;
      } else if (e.code == 'wrong-password') {
        return LoginStatus.wrongPassword;
      } else {
        return LoginStatus.unrecognizedError;
      }
    }
    return LoginStatus.success;
  }

  @override
  Future<LoginStatus> updatePassword(
      local_user.User user, String newPassword) async {
    final authenticator = FirebaseAuth.instance;
    try {
      await authenticator.currentUser?.updatePassword(newPassword);
    } catch (e) {
      return LoginStatus.couldNotCreateUser;
    }

    final id = emailToPath(user.email);
    try {
      await FirebaseDatabase.instance
          .ref(pathToAllUsers)
          .child('$id/${local_user.User.shouldChangePasswordNameField}')
          .set(false);
    } catch (e) {
      return LoginStatus.unrecognizedError;
    }
    return LoginStatus.success;
  }

  @override
  Future<LoginStatus> send({
    required local_user.User user,
    required String password,
  }) async {
    final authenticator = FirebaseAuth.instance;

    try {
      await authenticator.createUserWithEmailAndPassword(
          email: user.email, password: password);
    } catch (e) {
      return LoginStatus.couldNotCreateUser;
    }

    final id = emailToPath(user.email);
    try {
      await FirebaseDatabase.instance
          .ref(pathToAllUsers)
          .child(id)
          .set(user.serialize());
    } catch (e) {
      return LoginStatus.unrecognizedError;
    }
    return LoginStatus.success;
  }

  @override
  Future<local_user.User?> getUser(String email) async {
    final id = emailToPath(email);
    final data =
        await FirebaseDatabase.instance.ref('$pathToAllUsers/$id').get();
    return data.value == null
        ? null
        : local_user.User.fromSerialized(data.value);
  }
}

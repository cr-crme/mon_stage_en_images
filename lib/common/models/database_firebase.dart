import 'dart:io';

import 'package:defi_photo/crcrme_enhanced_containers/lib/item_serializable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import './database_abstract.dart';
import './enum.dart';
import '../../firebase_options.dart';

class DatabaseFirebase implements DataBaseAbstract {
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
    // authenticator.createUserWithEmailAndPassword(
    //     email: 'coucou@coucou.com', password: '123456');
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
    return LoginStatus.connected;
  }

  @override
  Future<void> send(String path, ItemSerializable item) async {
    return FirebaseDatabase.instance
        .ref(path)
        .child(item.id)
        .set(item.serialize());
  }

  @override
  Future<T> get<T>(String path) async {
    final map = FirebaseDatabase.instance.ref(path).get();
    final item = (T as ItemSerializable).deserializeItem(map);
    return item as T;
  }
}

import 'package:defi_photo/common/models/answer.dart';
import 'package:defi_photo/common/models/enum.dart';
import 'package:defi_photo/common/providers/all_answers.dart';
import 'package:defi_photo/common/providers/all_questions.dart';
import 'package:ezlogin/ezlogin.dart';
import 'package:firebase_auth/firebase_auth.dart' as fireauth;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

import 'user.dart';

export 'package:ezlogin/ezlogin.dart';

class Database extends EzloginFirebase with ChangeNotifier {
  ///
  /// This is an internal structure to quickly access the current
  /// user information. These may therefore be out of sync with the database

  // Rerefence to the database providers
  final questions = AllQuestions();
  final answers = AllAnswers();

  User? _currentUser;

  @override
  User? get currentUser => _currentUser;

  @override
  Future<void> initialize({bool useEmulator = false, currentPlatform}) async {
    final status = await super
        .initialize(useEmulator: useEmulator, currentPlatform: currentPlatform);

    if (super.currentUser != null) {
      await _postLogin();
    }
    return status;
  }

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
    if (status != EzloginStatus.success) return status;
    await _postLogin();
    return status;
  }

  Future<void> _postLogin() async {
    _currentUser = await user(fireauth.FirebaseAuth.instance.currentUser!.uid);
    notifyListeners();

    _fetchStudents();
    await _startFetchingData();
  }

  Future<void> _startFetchingData() async {
    /// this should be call only after user has successfully logged in

    await answers.initializeFetchingData();

    if (_currentUser!.userType == UserType.student) {
      questions.pathToData = 'questions/${_currentUser!.supervisedBy}';
    } else {
      questions.pathToData = 'questions/${_currentUser!.id}';
    }
    await questions.initializeFetchingData();
  }

  Future<void> _stopFetchingData() async {
    await answers.stopFetchingData();
    await questions.stopFetchingData();
  }

  @override
  Future<EzloginStatus> logout() async {
    _currentUser = null;
    await _stopFetchingData();
    notifyListeners();
    return super.logout();
  }

  @override
  Future<EzloginStatus> modifyUser(
      {required EzloginUser user, required EzloginUser newInfo}) async {
    final status = await super.modifyUser(user: user, newInfo: newInfo);
    if (user.email == currentUser?.email) {
      _currentUser = await this.user(user.id);
      notifyListeners();
    }
    return status;
  }

  @override
  Future<User?> user(String id) async {
    try {
      final data = await FirebaseDatabase.instance.ref('$usersPath/$id').get();
      return data.value == null ? null : User.fromSerialized(data.value);
    } on Exception {
      debugPrint('Error while fetching user $id');
      return null;
    }
  }

  @override
  Future<User?> userFromEmail(String email) async {
    final data = await FirebaseDatabase.instance
        .ref(usersPath)
        .orderByChild('email')
        .equalTo(email)
        .get();

    if (data.value == null) return null;

    return User.fromSerialized((data.value as Map?)!.values.first as Map);
  }

  final List<User> _students = [];
  Iterable<User> get students => [..._students];

  Future<void> _fetchStudents() async {
    if (_currentUser == null) return;

    // We only have access to our own information if we are a student
    if (_currentUser!.userType == UserType.student) {
      _students.clear();
      _students.add(_currentUser!);
      notifyListeners();
      return;
    }

    late final DataSnapshot data;
    try {
      data = await FirebaseDatabase.instance
          .ref('$usersPath/${_currentUser!.id}')
          .get();
    } on Exception {
      debugPrint('Error while fetching user ${_currentUser!.id}');
      return;
    }

    _students.clear();

    if (data.value != null) {
      for (final id
          in ((data.value! as Map)['supervising'] as Map? ?? {}).keys) {
        final student = await user(id);
        if (student != null) _students.add(student);
      }
    }

    notifyListeners();
  }

  Future<EzloginStatus> addStudent(
      {required User newStudent,
      required AllQuestions questions,
      required AllAnswers answers}) async {
    var newUser = await addUser(newUser: newStudent, password: 'defiPhoto');
    if (newUser == null) return EzloginStatus.alreadyCreated;

    newStudent = newStudent.copyWith(id: newUser.id);
    currentUser!.supervising[newStudent.id] = true;

    try {
      await FirebaseDatabase.instance
          .ref(usersPath)
          .child('${currentUser!.id}/supervising')
          .set(currentUser!.supervising);
    } on Exception {
      return EzloginStatus.unrecognizedError;
    }

    try {
      answers.addAnswers(questions.map((e) => Answer(
            isActive: e.defaultTarget == Target.all,
            actionRequired: ActionRequired.fromStudent,
            createdById: currentUser!.id,
            studentId: newStudent.id,
            questionId: e.id,
          )));
    } on Exception {
      return EzloginStatus.unrecognizedError;
    }

    _fetchStudents();
    return EzloginStatus.success;
  }

  Future<EzloginStatus> modifyStudent({required User newInfo}) async {
    final studentUser = await user(newInfo.id);
    if (studentUser == null) return EzloginStatus.userNotFound;

    final status = await modifyUser(user: studentUser, newInfo: newInfo);
    _fetchStudents();
    return status;
  }
}

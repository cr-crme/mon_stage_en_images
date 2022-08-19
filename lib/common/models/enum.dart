class TypeException implements Exception {
  TypeException(this.message);

  final String message;
}

enum Target {
  none,
  individual,
  all,
}

enum ActionRequired {
  none,
  fromStudent,
  fromTeacher,
}

enum LoginType {
  none,
  teacher,
  student,
}

enum LoginStatus {
  waitingForLogin,
  success,
  newUser,
  couldNotCreateUser,
  wrongUsername,
  wrongPassword,
  unrecognizedError,
  cancelled,
}

enum QuestionView {
  normal,
  modifyForOneStudent,
  modifyForAllStudents,
}

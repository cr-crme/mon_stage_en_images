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

enum UserType {
  none,
  teacher,
  student,
}

enum PageMode {
  fixView,
  editableView,
  edit,
}

enum AnswerFilterMode {
  byDate,
  byStudent,
}

enum AnswerFromWhoMode {
  studentOnly,
  teacherOnly,
  teacherAndStudent,
}

enum AnswerTypeMode {
  textOnly,
  photoOnly,
  textAndPhotos,
}

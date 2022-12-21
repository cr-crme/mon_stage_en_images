import 'package:ezlogin/ezlogin.dart';

import 'enum.dart';

class User extends EzloginUser {
  // Constructors and (de)serializer
  User({
    required this.firstName,
    required this.lastName,
    required super.email,
    required this.addedBy,
    required this.userType,
    required super.shouldChangePassword,
    this.studentId,
    super.id,
  });
  User.fromSerialized(map)
      : firstName = map['firstName'],
        lastName = map['lastName'],
        addedBy = map['addedBy'],
        userType = UserType.values[map['userType']],
        studentId = map['studentId'],
        super.fromSerialized(map);

  @override
  User copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? addedBy,
    UserType? userType,
    bool? shouldChangePassword,
    String? id,
  }) {
    firstName ??= this.firstName;
    lastName ??= this.lastName;
    email ??= this.email;
    addedBy ??= this.addedBy;
    userType ??= this.userType;
    shouldChangePassword ??= this.shouldChangePassword;
    id ??= this.id;
    return User(
      firstName: firstName,
      lastName: lastName,
      email: email,
      addedBy: addedBy,
      userType: userType,
      shouldChangePassword: shouldChangePassword,
      id: id,
    );
  }

  @override
  Map<String, dynamic> serializedMap() {
    return super.serializedMap()
      ..addAll({
        'firstName': firstName,
        'lastName': lastName,
        'addedBy': addedBy,
        'userType': userType.index,
        'studentId': studentId,
      });
  }

  @override
  User deserializeItem(map) {
    return User.fromSerialized(map);
  }

  // Attributes and methods
  final String firstName;
  final String lastName;
  final String addedBy;
  final UserType userType;
  final String? studentId;

  @override
  String toString() {
    return '$email added by $addedBy';
  }
}

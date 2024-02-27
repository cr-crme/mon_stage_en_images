import 'package:ezlogin/ezlogin.dart';

import 'enum.dart';

class User extends EzloginUser {
  // Constructors and (de)serializer
  User({
    required this.firstName,
    required this.lastName,
    required super.email,
    required this.addedBy,
    required this.supervisedBy,
    required this.supervising,
    required this.userType,
    required super.mustChangePassword,
    required this.companyNames,
    this.studentId,
    super.id,
  });

  User.fromSerialized(map)
      : firstName = map['firstName'],
        lastName = map['lastName'],
        addedBy = map['addedBy'],
        supervisedBy =
            (map['supervisedBy'] as List?)?.map((e) => e as String).toList() ??
                [],
        supervising =
            (map['supervising'] as List?)?.map((e) => e as String).toList() ??
                [],
        userType = UserType.values[map['userType'] as int],
        studentId = map['studentId'],
        companyNames =
            (map['companyNames'] as List?)?.map((e) => e as String).toList() ??
                [],
        super.fromSerialized(map);

  @override
  User copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? addedBy,
    List<String>? supervisedBy,
    List<String>? supervising,
    UserType? userType,
    bool? mustChangePassword,
    String? id,
    List<String>? companyNames,
  }) {
    firstName ??= this.firstName;
    lastName ??= this.lastName;
    email ??= this.email;
    addedBy ??= this.addedBy;
    supervisedBy ??= this.supervisedBy;
    supervising ??= this.supervising;
    userType ??= this.userType;
    mustChangePassword ??= this.mustChangePassword;
    id ??= this.id;
    companyNames ??= this.companyNames;
    return User(
      firstName: firstName,
      lastName: lastName,
      email: email,
      addedBy: addedBy,
      supervisedBy: supervisedBy,
      supervising: supervising,
      userType: userType,
      mustChangePassword: mustChangePassword,
      id: id,
      companyNames: companyNames,
    );
  }

  @override
  Map<String, dynamic> serializedMap() {
    return super.serializedMap()
      ..addAll({
        'firstName': firstName,
        'lastName': lastName,
        'addedBy': addedBy,
        'supervisedBy': supervisedBy,
        'supervising': supervising,
        'userType': userType.index,
        'studentId': studentId,
        'companyNames': companyNames,
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
  final List<String> supervisedBy;
  final List<String> supervising;
  final UserType userType;
  final String? studentId;
  final List<String> companyNames;

  @override
  String toString() {
    return '$email added by $addedBy';
  }
}

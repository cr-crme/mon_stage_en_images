import 'package:ezlogin/ezlogin.dart';

import 'enum.dart';

class User extends EzloginUser {
  // Constructors and (de)serializer
  User({
    required this.firstName,
    required this.lastName,
    required super.email,
    required this.supervisedBy,
    required this.supervising,
    required this.userType,
    required super.mustChangePassword,
    required this.companyNames,
    super.id,
  });

  User.fromSerialized(super.map)
      : firstName = map['firstName'],
        lastName = map['lastName'],
        supervisedBy = map['supervisedBy'],
        supervising =
            (map['supervising'] as Map?)?.map((k, v) => MapEntry(k, v)) ?? {},
        userType = UserType.values[map['userType'] as int],
        companyNames = map['companyNames'],
        super.fromSerialized();

  @override
  User copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? supervisedBy,
    Map<String, bool>? supervising,
    UserType? userType,
    bool? mustChangePassword,
    String? id,
    String? companyNames,
  }) {
    firstName ??= this.firstName;
    lastName ??= this.lastName;
    email ??= this.email;
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
      supervisedBy: supervisedBy,
      supervising: supervising,
      userType: userType,
      mustChangePassword: mustChangePassword,
      id: id,
      companyNames: companyNames,
    );
  }

  @override
  Map<String, dynamic> serializedMap() => super.serializedMap()
    ..addAll({
      'firstName': firstName,
      'lastName': lastName,
      'supervisedBy': supervisedBy,
      'supervising': supervising,
      'userType': userType.index,
      'companyNames': companyNames,
    });

  @override
  User deserializeItem(map) {
    return User.fromSerialized(map);
  }

  // Attributes and methods
  final String firstName;
  final String lastName;
  final String supervisedBy;
  final Map<String, bool> supervising;
  final UserType userType;
  final String companyNames;

  @override
  String toString() => '$firstName $lastName';
}

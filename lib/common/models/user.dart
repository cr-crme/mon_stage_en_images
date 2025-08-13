import 'package:ezlogin/ezlogin.dart';
import 'package:mon_stage_en_images/common/misc/database_helper.dart';

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
    required this.termsAndServicesAccepted,
    required this.creationDate,
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
        termsAndServicesAccepted = map['termsAndServicesAccepted'] ?? false,
        creationDate =
            DateTime.parse(map['creationDate'] ?? defaultCreationDate),
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
    bool? termsAndServicesAccepted,
    DateTime? creationDate,
  }) {
    return User(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      supervisedBy: supervisedBy ?? this.supervisedBy,
      supervising: supervising ?? this.supervising,
      userType: userType ?? this.userType,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      id: id ?? this.id,
      companyNames: companyNames ?? this.companyNames,
      termsAndServicesAccepted:
          termsAndServicesAccepted ?? this.termsAndServicesAccepted,
      creationDate: creationDate ?? this.creationDate,
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
      'termsAndServicesAccepted': termsAndServicesAccepted,
      'creationDate': creationDate.toIso8601String(),
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
  final bool termsAndServicesAccepted;
  final DateTime creationDate;

  bool get isActive => creationDate.isAfter(isActiveLimitDate);
  bool get isNotActive => !isActive;

  @override
  String toString() => '$firstName $lastName';
}

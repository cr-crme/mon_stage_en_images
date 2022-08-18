import 'package:defi_photo/crcrme_enhanced_containers/lib/item_serializable.dart';

String emailToPath(String email) {
  return 'tata__arobas__coucou__dot__com';
}

class User extends ItemSerializable {
  // Constructors and (de)serializer
  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.addedBy,
  }) : super(id: emailToPath(email));
  User.fromSerialized(map)
      : firstName = map['firstName'],
        lastName = map['lastName'],
        email = map['email'],
        addedBy = map['addedBy'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'addedBy': addedBy,
    };
  }

  @override
  User deserializeItem(map) {
    return User.fromSerialized(map);
  }

  // Attributes and methods
  final String firstName;
  final String lastName;
  final String email;
  final String addedBy;

  @override
  String toString() {
    return '$email added by $addedBy';
  }
}

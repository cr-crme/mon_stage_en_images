import '../providers/provider_models/provided_item.dart';

class Student extends ProvidedItem {
  final String firstName;
  final String lastName;

  final int progression;

  Student({
    required this.firstName,
    required this.lastName,
    this.progression = 0,
  });

  @override
  Student.fromSerialized(Map<String, dynamic> map)
      : firstName = map['firstName'],
        lastName = map['lastName'],
        progression = 0,
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'progression': progression,
    };
  }

  @override
  Student deserializeItem(Map<String, dynamic> map) {
    return Student.fromSerialized(map);
  }

  @override
  String toString() {
    return '$firstName $lastName';
  }
}

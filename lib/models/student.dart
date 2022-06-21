import '../providers/provider_models/item_serializable.dart';

import './company.dart';

class Student extends ItemSerializable {
  final String firstName;
  final String lastName;

  Company? company;

  Student({
    required this.firstName,
    required this.lastName,
    this.company,
    id,
  }) : super(id: id);

  @override
  Student.fromSerialized(Map<String, dynamic> map)
      : firstName = map['firstName'],
        lastName = map['lastName'],
        company = map['company'],
        super.fromSerialized(map);

  // String get progression => '$nbQuestionsAnswered / $nbQuestionsTotal';

  // int get nbQuestionsAnswered {
  //   int sum = 0;
  //   for (var element in qAndABySections) {
  //     sum += element.nbQuestionsAnswered;
  //   }
  //   return sum;
  // }

  // int get nbQuestionsTotal {
  //   int sum = 0;
  //   for (var element in qAndABySections) {
  //     sum += element.length;
  //   }
  //   return sum;
  // }

  Student copyWith({
    firstName,
    lastName,
    company,
    id,
  }) {
    firstName ??= this.firstName;
    lastName ??= this.lastName;
    company ??= this.company;
    id ??= this.id;
    return Student(
      firstName: firstName,
      lastName: lastName,
      company: company,
      id: id,
    );
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'company': company,
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

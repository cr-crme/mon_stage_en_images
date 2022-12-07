import 'package:enhanced_containers/enhanced_containers.dart';

import 'all_answers.dart';
import 'company.dart';

class Student extends ItemSerializableWithCreationTime {
  // Constructors and (de)serializer
  Student({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.company,
    required this.allAnswers,
    super.id,
    super.creationTimeStamp,
  });

  Student copyWith({
    String? firstName,
    String? lastName,
    String? email,
    Company? company,
    AllAnswers? allAnswers,
    String? id,
    int? creationTimeStamp,
  }) {
    firstName ??= this.firstName;
    lastName ??= this.lastName;
    email ??= this.email;
    company ??= this.company;
    allAnswers ??= this.allAnswers;
    id ??= this.id;
    creationTimeStamp ??= this.creationTimeStamp;
    return Student(
      firstName: firstName,
      lastName: lastName,
      email: email,
      company: company,
      allAnswers: allAnswers,
      id: id,
      creationTimeStamp: creationTimeStamp,
    );
  }

  @override
  Student.fromSerialized(map)
      : firstName = map['firstName'],
        lastName = map['lastName'],
        email = map['email'],
        allAnswers = AllAnswers.fromSerialized(map['allAnswers'] ?? {}),
        company = Company.fromSerialized((map['company'] ?? {})),
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'allAnswers': allAnswers.serialize(),
      'company': company.serialize(),
    };
  }

  Student deserializeItem(map) {
    return Student.fromSerialized(map);
  }

  // Attributes and methods
  final String firstName;
  final String lastName;
  final String email;
  final AllAnswers allAnswers;
  final Company company;

  int get nbQuestionsAnswered {
    int sum = 0;
    for (var element in allAnswers) {
      sum += element.value.isAnswered ? 1 : 0;
    }
    return sum;
  }

  @override
  String toString() {
    return '$firstName $lastName';
  }
}

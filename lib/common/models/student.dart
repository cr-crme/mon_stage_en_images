import 'package:defi_photo/crcrme_enhanced_containers/lib/creation_time_item_serializable.dart';

import './all_answers.dart';
import './company.dart';

class Student extends CreationTimeItemSerializable {
  // Constructors and (de)serializer
  Student({
    required this.firstName,
    required this.lastName,
    required this.company,
    required this.allAnswers,
    String? id,
    int? creationTimeStamp,
  }) : super(id: id, creationTimeStamp: creationTimeStamp);

  Student copyWith({
    String? firstName,
    String? lastName,
    Company? company,
    AllAnswers? allAnswers,
    String? id,
    int? creationTimeStamp,
  }) {
    firstName ??= this.firstName;
    lastName ??= this.lastName;
    company ??= this.company;
    allAnswers ??= this.allAnswers;
    id ??= this.id;
    creationTimeStamp ??= this.creationTimeStamp;
    return Student(
      firstName: firstName,
      lastName: lastName,
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
        allAnswers = AllAnswers.fromSerialized(map['allAnswers'] ?? {}),
        company = Company.fromSerialized((map['company'] ?? {})),
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'allAnswers': allAnswers.serialize(),
      'company': company.serialize(),
    };
  }

  @override
  Student deserializeItem(map) {
    return Student.fromSerialized(map);
  }

  // Attributes and methods
  final String firstName;
  final String lastName;
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

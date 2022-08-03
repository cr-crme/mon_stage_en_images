import './all_answers.dart';
import './company.dart';

import '../../misc/custom_containers/item_serializable.dart';

class Student extends ItemSerializable {
  // Constructors and (de)serializer
  Student({
    required this.firstName,
    required this.lastName,
    required this.company,
    required this.allAnswers,
    id,
  }) : super(id: id);

  Student copyWith({firstName, lastName, company, allAnswers, id}) {
    firstName ??= this.firstName;
    lastName ??= this.lastName;
    company ??= this.company;
    allAnswers ??= this.allAnswers;
    id ??= this.id;
    return Student(
      firstName: firstName,
      lastName: lastName,
      company: company,
      allAnswers: allAnswers,
      id: id,
    );
  }

  @override
  Student.fromSerialized(Map<String, dynamic> map)
      : firstName = map['firstName'],
        lastName = map['lastName'],
        allAnswers = map['allAnswers'],
        company = map['company'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'allAnswers': allAnswers,
      'company': company,
    };
  }

  @override
  Student deserializeItem(Map<String, dynamic> map) {
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
      sum += element.value.isAnswered() ? 1 : 0;
    }
    return sum;
  }

  @override
  String toString() {
    return '$firstName $lastName';
  }
}

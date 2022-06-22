import './company.dart';
import 'all_answer.dart';
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

  Student copyWith({
    firstName,
    lastName,
    company,
    allAnswers,
    id,
  }) {
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
  final AllAnswer allAnswers;
  final Company company;

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

  @override
  String toString() {
    return '$firstName $lastName';
  }
}

import 'package:defi_photo/providers/list_serializable.dart';

import 'list_provided.dart';
import './provider_models/exceptions.dart';
import '../models/question.dart';

class QuestionList with ListSerializable<Question> {
  QuestionList();
  QuestionList.fromSerialized(map) {
    deserialize(map);
  }

  // int get nbQuestionsAnswered {
  //   int sum = 0;
  //   for (var element in items) {
  //     sum += element.answered ? 1 : 0;
  //   }
  //   return sum;
  // }

  @override
  Question deserializeItem(map) {
    return Question.fromSerialized(map);
  }
}

class AllQuestionsLists extends ListProvided<QuestionList> {
  final int nbSections = 6;

  AllQuestionsLists() : super() {
    _initialize();
  }

  AllQuestionsLists.fromSerialized(map) {
    for (var element in (map['metier'] as List<Map<String, dynamic>>)) {
      items.add(QuestionList.fromSerialized(element));
    }
  }

  void _initialize() {
    for (int i = 0; i < nbSections; ++i) {
      items.add(QuestionList());
    }
  }

  @override
  operator [](value) {
    if (value is int && value >= nbSections) {
      throw ValueException('Number of elements are limited to $nbSections');
    }
    return super[value];
  }

  @override
  void add(QuestionList item, {bool notify = true}) {
    throw const ShouldNotCall('Add should not be called by the user');
  }

  @override
  QuestionList deserializeItem(map) {
    return QuestionList.fromSerialized(map);
  }
}

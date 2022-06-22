import 'package:defi_photo/providers/list_serializable.dart';
import 'package:flutter/material.dart';

import 'list_provided.dart';
import './provider_models/exceptions.dart';
import '../models/question.dart';

class QuestionList with ListSerializable<Question> {
  QuestionList();
  QuestionList.fromSerialized(map) {
    deserialize(map);
  }

  @override
  Question deserializeItem(map) {
    return Question.fromSerialized(map);
  }
}

class AllQuestionList extends ListProvided<QuestionList> {
  final int nbSections = 6;

  static String letter(index) {
    switch (index) {
      case 0:
        return 'M';
      case 1:
        return 'É';
      case 2:
        return 'T';
      case 3:
        return 'I';
      case 4:
        return 'E';
      case 5:
        return 'R';
      default:
        throw const ValueException('Number of elements are limited to 6');
    }
  }

  static MaterialColor color(index) {
    switch (index) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.green;
      case 4:
        return Colors.blue;
      case 5:
        return Colors.purple;
      default:
        throw const ValueException('Number of elements are limited to 6');
    }
  }

  AllQuestionList() : super() {
    _initialize();
  }

  AllQuestionList.fromSerialized(map) {
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
  QuestionList operator [](value) {
    if (value is int && value >= nbSections) {
      throw ValueException('Number of elements are limited to $nbSections');
    }
    return super[value]!;
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

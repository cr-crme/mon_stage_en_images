import 'package:flutter/material.dart';

import '../models/question_list.dart';
import '../../misc/custom_list/list_provided.dart';
import '../../misc/exceptions.dart';

class AllQuestionList extends ListProvided<QuestionList> {
  final int nbSections = 6;

  static String letter(index) {
    return 'MÉTIER'[index];
  }

  static MaterialColor color(index) {
    return [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
    ][index];
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

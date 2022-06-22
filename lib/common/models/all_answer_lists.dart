import 'package:defi_photo/misc/custom_list/list_serializable.dart';

import './answer_list.dart';
import './section.dart';
import '../../misc/exceptions.dart';

class AllAnswerList extends ListSerializable<AnswerList> with Section {
  // Constructors and (de)serializer
  AllAnswerList() : super() {
    _initialize();
  }

  void _initialize() {
    for (int i = 0; i < nbSections; ++i) {
      items.add(AnswerList());
    }
  }

  AllAnswerList.fromSerialized(map) {
    for (var element in (map['metier'] as List<Map<String, dynamic>>)) {
      items.add(AnswerList.fromSerialized(element));
    }
  }

  @override
  AnswerList deserializeItem(map) {
    return AnswerList.fromSerialized(map);
  }

  // Attributes and methods
  int get number => length;

  @override
  AnswerList operator [](value) {
    if (value is int && value >= nbSections) {
      throw ValueException('Number of elements are limited to $nbSections');
    }
    return super[value]!;
  }

  @override
  void add(AnswerList item, {bool notify = true}) {
    throw const ShouldNotCall('Add should not be called by the user');
  }
}

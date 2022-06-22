import '../models/question_list.dart';
import '../models/section.dart';
import '../../misc/custom_containers/list_provided.dart';
import '../../misc/exceptions.dart';

class AllQuestionList extends ListProvided<QuestionList> with Section {
  // Constructors and (de)serializer
  AllQuestionList() : super() {
    _initialize();
  }

  void _initialize() {
    for (int i = 0; i < nbSections; ++i) {
      items.add(QuestionList());
    }
  }

  AllQuestionList.fromSerialized(map) {
    for (var element in (map['metier'] as List<Map<String, dynamic>>)) {
      items.add(QuestionList.fromSerialized(element));
    }
  }

  @override
  QuestionList deserializeItem(map) {
    return QuestionList.fromSerialized(map);
  }

  // Attributes and methods
  int get number => length;

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
}

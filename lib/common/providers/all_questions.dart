import '../models/question.dart';
import '../models/section.dart';
import '../../misc/custom_containers/list_provided.dart';

class AllQuestions extends ListProvided<Question> with Section {
  // Constructors and (de)serializer
  AllQuestions() : super();
  AllQuestions.fromSerialized(map) : super.fromSerialized(map);

  @override
  Question deserializeItem(map) {
    return Question.fromSerialized(map);
  }

  AllQuestions fromSection(index) {
    final out = AllQuestions();
    forEach((question) {
      if (question.section == index) out.add(question);
    });
    return out;
  }

  // Attributes and methods
  int get number => length;
}

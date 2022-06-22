import '../models/question.dart';
import '../../misc/custom_list/list_serializable.dart';

class QuestionList with ListSerializable<Question> {
  QuestionList();
  QuestionList.fromSerialized(map) {
    deserialize(map);
  }

  @override
  Question deserializeItem(map) {
    return Question.fromSerialized(map);
  }

  int get number => length;
}

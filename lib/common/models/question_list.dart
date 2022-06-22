import '../models/question.dart';
import '../../misc/custom_containers/list_serializable.dart';

class QuestionList extends ListSerializable<Question> {
  QuestionList();
  QuestionList.fromSerialized(Map<String, dynamic> map)
      : super.fromSerialized(map);

  @override
  Question deserializeItem(map) {
    return Question.fromSerialized(map);
  }

  int get number => length;
}

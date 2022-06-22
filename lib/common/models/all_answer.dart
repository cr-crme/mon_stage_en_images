import './answer.dart';
import '../../misc/custom_containers/map_serializable.dart';

class AllAnswer extends MapSerializable<Answer> {
  // Constructors and (de)serializer
  AllAnswer();
  AllAnswer.fromSerialized(map) : super.fromSerialized(map);

  @override
  Answer deserializeItem(map) {
    return Answer.fromSerialized(map);
  }

  @override
  void add(Answer item) => items[item.question.id] = item;

  // Attributes and methods
  int get number => length;
}

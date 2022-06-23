import './answer.dart';
import '../../misc/custom_containers/map_serializable.dart';

class AllAnswers extends MapSerializable<Answer> {
  // Constructors and (de)serializer
  AllAnswers();
  AllAnswers.fromSerialized(map) : super.fromSerialized(map);

  @override
  Answer deserializeItem(map) {
    return Answer.fromSerialized(map);
  }

  // Attributes and methods
  int get number => length;
  int get numberAnswered {
    int answered = 0;
    forEach((answer) {
      if (answer.value.isAnswered) answered++;
    });
    return answered;
  }

  @override
  void add(Answer item) => items[item.question.id] = item;

  AllAnswers fromSection(index) {
    final AllAnswers out = AllAnswers();
    forEach((answer) {
      if (answer.value.question.section == index) out.add(answer.value);
    });
    return out;
  }
}

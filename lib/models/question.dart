import '../providers/provider_models/item_serializable.dart';

class Question extends ItemSerializable {
  final String question;

  Question(this.question);
  Question.fromSerialized(Map<String, dynamic> map)
      : question = map['question'],
        super.fromSerialized(map);

  @override
  ItemSerializable deserializeItem(Map<String, dynamic> map) {
    return Question(map['question']);
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'question': question,
    };
  }
}

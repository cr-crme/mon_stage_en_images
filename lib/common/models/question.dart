import '../../misc/custom_containers/item_serializable.dart';
import '../../common/models/enum.dart';

class Question extends ItemSerializable {
  // Constructors and (de)serializer
  Question(this.text,
      {required this.type, required this.section});
  Question.fromSerialized(Map<String, dynamic> map)
      : text = map['text'],
        type = map['type'],
        section = map['section'],
        super.fromSerialized(map);

  @override
  ItemSerializable deserializeItem(Map<String, dynamic> map) {
    return Question.fromSerialized(map);
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'text': text,
      'type': type,
      'section': section,
    };
  }

  // Attributes and methods
  final String text;
  QuestionType type;
  final int section;
}

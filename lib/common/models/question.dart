import '../../misc/custom_containers/item_serializable.dart';
import '../../common/models/enum.dart';

class Question extends ItemSerializable {
  // Constructors and (de)serializer
  Question(this.text,
      {required this.type,
      required this.section,
      required this.defaultTarget,
      id})
      : super(id: id);
  Question.fromSerialized(Map<String, dynamic> map)
      : text = map['text'],
        type = map['type'],
        section = map['section'],
        defaultTarget = map['defaultTarget'],
        super.fromSerialized(map);
  Question copyWith({text, type, section, defaultTarget, id}) {
    text ??= this.text;
    type ??= this.type;
    section ??= this.section;
    defaultTarget ??= this.defaultTarget;
    id ??= this.id;
    return Question(
      text,
      type: type,
      section: section,
      defaultTarget: defaultTarget,
      id: id,
    );
  }

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
      'defaultTarget': defaultTarget,
    };
  }

  // Attributes and methods
  final String text;
  final QuestionType type;
  final int section;
  final Target defaultTarget;
}

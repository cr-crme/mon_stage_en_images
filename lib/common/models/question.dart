import '../../misc/custom_containers/item_serializable.dart';
import '../../common/models/enum.dart';

class Question extends ItemSerializable {
  // Constructors and (de)serializer
  Question(this.text,
      {required this.needPhoto, required this.needText, required this.section});
  Question.fromSerialized(Map<String, dynamic> map)
      : text = map['text'],
        needPhoto = map['needPhoto'],
        needText = map['isWrittenRequired'],
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
      'needPhoto': needPhoto,
      'isWrittenRequired': needText,
      'section': section,
    };
  }

  QuestionType get type => needPhoto ? QuestionType.photo : QuestionType.text;
  set type(QuestionType value) {
    needPhoto = value == QuestionType.photo;
    needText = value == QuestionType.text;
  }

  // Attributes and methods
  final String text;
  bool needPhoto;
  bool needText;
  final int section;
}

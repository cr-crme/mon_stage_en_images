import '../../misc/custom_list/item_serializable.dart';

class Question extends ItemSerializable {
  // Constructors and (de)serializer
  Question(this.text, {required this.needPhoto, required this.needText});
  Question.fromSerialized(Map<String, dynamic> map)
      : text = map['text'],
        needPhoto = map['needPhoto'],
        needText = map['isWrittenRequired'],
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
    };
  }

  // Attributes and methods
  final String text;
  final bool needPhoto;
  final bool needText;
}

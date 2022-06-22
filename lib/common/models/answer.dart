import '../../misc/custom_list/item_serializable.dart';

class Answer extends ItemSerializable {
  // Constructors and (de)serializer
  Answer({
    required this.questionId,
    required this.needText,
    this.text,
    required this.needPhoto,
    this.photoUrl,
  });
  Answer.fromSerialized(Map<String, dynamic> map)
      : questionId = map['questionId'],
        needText = map['needText'],
        text = map['text'],
        needPhoto = map['needPhoto'],
        photoUrl = map['photoUrl'],
        super.fromSerialized(map);

  @override
  ItemSerializable deserializeItem(Map<String, dynamic> map) {
    return Answer.fromSerialized(map);
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'questionId': questionId,
      'needText': needText,
      'text': text,
      'needPhoto': needPhoto,
      'photoUrl': photoUrl,
    };
  }

  // Attributes and methods
  final String questionId;
  final bool needText;
  final String? text;
  final bool needPhoto;
  final String? photoUrl;

  bool get isTextAnswered => !needText || (needText && text != null);
  bool get isPhotoAnswered => !needPhoto || (needPhoto && photoUrl != null);

  bool get isAnswered {
    return isTextAnswered && isPhotoAnswered;
  }
}

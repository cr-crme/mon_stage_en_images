import '../models/question.dart';
import '../../misc/custom_list/item_serializable.dart';

class Answer extends ItemSerializable {
  // Constructors and (de)serializer
  Answer({
    required this.question,
    this.text,
    this.photoUrl,
  });
  Answer.fromSerialized(Map<String, dynamic> map)
      : question = map['question'],
        text = map['text'],
        photoUrl = map['photoUrl'],
        super.fromSerialized(map);

  @override
  ItemSerializable deserializeItem(Map<String, dynamic> map) {
    return Answer.fromSerialized(map);
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'question': question,
      'text': text,
      'photoUrl': photoUrl,
    };
  }

  // Attributes and methods
  final Question question;
  final String? text;
  final String? photoUrl;

  bool get needText => question.needText;
  bool get needPhoto => question.needPhoto;

  bool get isTextAnswered => !needText || (needText && text != null);
  bool get isPhotoAnswered => !needPhoto || (needPhoto && photoUrl != null);

  bool get isAnswered {
    return isTextAnswered && isPhotoAnswered;
  }
}

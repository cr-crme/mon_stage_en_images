import '../models/question.dart';
import '../../misc/custom_containers/item_serializable.dart';

class Answer extends ItemSerializable {
  // Constructors and (de)serializer
  Answer({
    required this.isActive,
    required this.question,
    this.text,
    this.photoUrl,
  });
  Answer.fromSerialized(Map<String, dynamic> map)
      : isActive = map['isActive'],
        question = map['question'],
        text = map['text'],
        photoUrl = map['photoUrl'],
        super.fromSerialized(map);

  @override
  Answer deserializeItem(Map<String, dynamic> map) {
    return Answer.fromSerialized(map);
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'isActive': isActive,
      'question': question,
      'text': text,
      'photoUrl': photoUrl,
    };
  }

  // Attributes and methods
  final bool isActive;
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

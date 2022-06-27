import 'message.dart';
import '../../common/models/enum.dart';
import '../../misc/custom_containers/item_serializable.dart';

class Answer extends ItemSerializable {
  // Constructors and (de)serializer
  Answer({
    required this.isActive,
    this.text,
    this.photoUrl,
    required this.discussion,
    id,
  }) : super(id: id);
  Answer.fromSerialized(Map<String, dynamic> map)
      : isActive = map['isActive'],
        text = map['text'],
        photoUrl = map['photoUrl'],
        discussion = map['discussion'],
        super.fromSerialized(map);
  Answer copyWith({isActive, text, photoUrl, discussion, id}) {
    isActive ??= this.isActive;
    text ??= this.text;
    photoUrl ??= this.photoUrl;
    discussion ??= this.discussion;
    id ??= this.id;
    return Answer(
      isActive: isActive,
      text: text,
      photoUrl: photoUrl,
      discussion: discussion,
      id: id,
    );
  }

  @override
  Answer deserializeItem(Map<String, dynamic> map) {
    return Answer.fromSerialized(map);
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'isActive': isActive,
      'text': text,
      'photoUrl': photoUrl,
      'discussion': discussion,
    };
  }

  // Attributes and methods
  final bool isActive;
  final String? text;
  final String? photoUrl;
  final List<Message> discussion;

  bool isTextAnswered(QuestionType qType) =>
      (qType == QuestionType.text || qType == QuestionType.any) && text != null;
  bool isPhotoAnswered(QuestionType qType) =>
      (qType == QuestionType.photo || qType == QuestionType.any) &&
      photoUrl != null;
  bool isAnswered(QuestionType qType) =>
      isTextAnswered(qType) || isPhotoAnswered(qType);

  void addMessage(Message message) => discussion.add(message);
}

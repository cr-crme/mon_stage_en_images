import 'message.dart';
import './question.dart';
import '../../common/models/enum.dart';
import '../../misc/custom_containers/item_serializable.dart';

class Answer extends ItemSerializable {
  // Constructors and (de)serializer
  Answer({
    required this.isActive,
    required this.question,
    this.text,
    this.photoUrl,
    required this.discussion,
    id,
  }) : super(id: id);
  Answer.fromSerialized(Map<String, dynamic> map)
      : isActive = map['isActive'],
        question = map['question'],
        text = map['text'],
        photoUrl = map['photoUrl'],
        discussion = map['discussion'],
        super.fromSerialized(map);
  Answer copyWith({isActive, question, text, photoUrl, discussion, id}) {
    isActive ??= this.isActive;
    question ??= this.question;
    text ??= this.text;
    photoUrl ??= this.photoUrl;
    discussion ??= this.discussion;
    id ??= this.id;
    return Answer(
      isActive: isActive,
      question: question,
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
      'question': question,
      'text': text,
      'photoUrl': photoUrl,
      'discussion': discussion,
    };
  }

  // Attributes and methods
  final bool isActive;
  final Question question;
  final String? text;
  final String? photoUrl;
  final List<Message> discussion;

  bool get isTextAnswered => question.type == QuestionType.text && text != null;
  bool get isPhotoAnswered =>
      question.type == QuestionType.photo && photoUrl != null;
  bool get isAnswered => isTextAnswered || isPhotoAnswered;

  void addMessage(Message message) => discussion.add(message);
}

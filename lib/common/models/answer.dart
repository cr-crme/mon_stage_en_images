import 'message.dart';
import '../../common/models/enum.dart';
import '../../misc/custom_containers/item_serializable.dart';

class Answer extends ItemSerializable {
  // Constructors and (de)serializer
  Answer({
    required this.status,
    this.text,
    this.photoUrl,
    required this.discussion,
    id,
  }) : super(id: id);
  Answer.fromSerialized(Map<String, dynamic> map)
      : status = map['status'],
        text = map['text'],
        photoUrl = map['photoUrl'],
        discussion = map['discussion'],
        super.fromSerialized(map);
  Answer copyWith({status, text, photoUrl, discussion, id}) {
    status ??= this.status;
    text ??= this.text;
    photoUrl ??= this.photoUrl;
    discussion ??= this.discussion;
    id ??= this.id;
    return Answer(
      status: status,
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
      'status': status,
      'text': text,
      'photoUrl': photoUrl,
      'discussion': discussion,
    };
  }

  // Attributes and methods
  final AnswerStatus status;
  final String? text;
  final String? photoUrl;
  final List<Message> discussion;

  bool get isActive {
    return status != AnswerStatus.deactivated;
  }

  bool get isValidated {
    return status == AnswerStatus.validated;
  }

  bool get needTeacherAction {
    return status == AnswerStatus.needTeacherAction;
  }

  bool get needStudentAction {
    return status == AnswerStatus.needStudentAction;
  }

  bool isTextAnswered(QuestionType qType) =>
      (qType == QuestionType.text || qType == QuestionType.any) && text != null;
  bool isPhotoAnswered(QuestionType qType) =>
      (qType == QuestionType.photo || qType == QuestionType.any) &&
      photoUrl != null;
  bool isAnswered({QuestionType questionType = QuestionType.any}) =>
      isTextAnswered(questionType) || isPhotoAnswered(questionType);

  void addMessage(Message message) => discussion.add(message);
}

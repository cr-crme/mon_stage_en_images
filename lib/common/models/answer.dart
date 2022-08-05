import 'message.dart';
import '../../common/models/enum.dart';
import '../../misc/custom_containers/item_serializable.dart';

class Answer extends ItemSerializable {
  // Constructors and (de)serializer
  Answer({
    this.photoUrl,
    List<Message>? discussion,
    this.isActive = true,
    this.isValidated = false,
    ActionRequired action = ActionRequired.none,
    id,
  })  : discussion = discussion ??= [],
        _action = action,
        super(id: id);
  Answer.fromSerialized(Map<String, dynamic> map)
      : isActive = map['isActive'],
        photoUrl = map['photoUrl'],
        discussion = map['discussion'],
        isValidated = map['isValidated'],
        _action = map['action'],
        super.fromSerialized(map);
  Answer copyWith(
      {isActive, text, photoUrl, discussion, isValidated, action, id}) {
    isActive ??= this.isActive;
    photoUrl ??= this.photoUrl;
    discussion ??= this.discussion;
    isValidated ??= this.isValidated;
    action ??= _action;
    id ??= this.id;
    return Answer(
      isActive: isActive,
      photoUrl: photoUrl,
      discussion: discussion,
      isValidated: isValidated,
      action: action,
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
      'photoUrl': photoUrl,
      'discussion': discussion,
      'isValidated': isValidated,
      'action': _action,
    };
  }

  // Attributes and methods
  final bool isActive;
  final String? photoUrl;
  final List<Message> discussion;
  final bool isValidated;
  final ActionRequired _action;
  ActionRequired get action => isActive ? _action : ActionRequired.none;
  bool get isAnswered => action != ActionRequired.fromStudent;

  void addMessage(Message message) => discussion.add(message);
}

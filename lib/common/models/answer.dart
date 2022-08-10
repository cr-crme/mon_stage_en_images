import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'message.dart';
import '../models/enum.dart';
import '../models/exceptions.dart';
import '../providers/login_information.dart';
import '../../misc/custom_containers/item_serializable.dart';

class Answer extends ItemSerializable {
  // Constructors and (de)serializer
  Answer({
    List<Message>? discussion,
    this.isActive = true,
    this.isValidated = false,
    ActionRequired actionRequired = ActionRequired.none,
    id,
  })  : discussion = discussion ??= [],
        _actionRequired = actionRequired,
        super(id: id);
  Answer.fromSerialized(Map<String, dynamic> map)
      : discussion = map['discussion'],
        isActive = map['isActive'],
        isValidated = map['isValidated'],
        _actionRequired = map['actionRequired'],
        super.fromSerialized(map);
  Answer copyWith(
      {discussion, isActive, text, isValidated, actionRequired, id}) {
    discussion ??= this.discussion;
    isActive ??= this.isActive;
    isValidated ??= this.isValidated;
    actionRequired ??= _actionRequired;
    id ??= this.id;
    return Answer(
      discussion: discussion,
      isActive: isActive,
      isValidated: isValidated,
      actionRequired: actionRequired,
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
      'discussion': discussion,
      'isActive': isActive,
      'isValidated': isValidated,
      'actionRequired': _actionRequired,
    };
  }

  // Attributes and methods
  final bool isActive;
  final List<Message> discussion;
  final bool isValidated;
  final ActionRequired _actionRequired;
  ActionRequired action(BuildContext context) {
    if (!isActive) return ActionRequired.none;

    final loginType =
        Provider.of<LoginInformation>(context, listen: false).loginType;
    if (loginType == LoginType.none) {
      throw const NotLoggedIn();
    }

    if (loginType == LoginType.student &&
        _actionRequired == ActionRequired.fromStudent) {
      return ActionRequired.fromStudent;
    } else if (loginType == LoginType.teacher &&
        _actionRequired == ActionRequired.fromTeacher) {
      return ActionRequired.fromTeacher;
    } else {
      return ActionRequired.none;
    }
  }

  bool get isAnswered =>
      isActive && _actionRequired != ActionRequired.fromStudent;
  bool get hasAnswer => discussion.isNotEmpty;

  void addToDiscussion(Message message) => discussion.add(message);
}

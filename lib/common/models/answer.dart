import 'package:defi_photo/common/models/database.dart';
import 'package:defi_photo/common/models/discussion.dart';
import 'package:defi_photo/common/models/enum.dart';
import 'package:defi_photo/common/models/exceptions.dart';
import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'message.dart';

class Answer extends ItemSerializable {
  // Constructors and (de)serializer
  Answer({
    Discussion? discussion,
    this.isActive = true,
    this.isValidated = false,
    this.actionRequired = ActionRequired.none,
    required this.createdById,
    required this.studentId,
    required String questionId,
  })  : discussion = discussion ??= Discussion(),
        super(id: questionId);
  Answer.fromSerialized(map)
      : discussion = Discussion.fromSerialized(map['discussion'] ?? {}),
        isActive = map['isActive'],
        isValidated = map['isValidated'],
        actionRequired = ActionRequired.values[map['actionRequired']],
        createdById = map['createdById'],
        studentId = map['studentId'],
        super.fromSerialized(map);
  Answer copyWith({
    Discussion? discussion,
    bool? isActive,
    bool? isValidated,
    ActionRequired? actionRequired,
    String? createdById,
    String? studentId,
    String? questionId,
    int? creationTimeStamp,
  }) {
    discussion ??= this.discussion;
    isActive ??= this.isActive;
    isValidated ??= this.isValidated;
    actionRequired ??= this.actionRequired;
    createdById ??= this.createdById;
    studentId ??= this.studentId;
    questionId ??= id;
    return Answer(
      discussion: discussion,
      isActive: isActive,
      isValidated: isValidated,
      actionRequired: actionRequired,
      createdById: createdById,
      studentId: studentId,
      questionId: questionId,
    );
  }

  String get questionId => id;

  Answer deserializeItem(map) {
    return Answer.fromSerialized(map);
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'discussion': discussion.serialize(),
      'isActive': isActive,
      'isValidated': isValidated,
      'actionRequired': actionRequired.index,
      'createdById': createdById,
      'studentId': studentId,
    };
  }

  // Attributes and methods
  final bool isActive;
  final Discussion discussion;
  final bool isValidated;
  final ActionRequired actionRequired;
  final String createdById;
  final String studentId;
  ActionRequired action(BuildContext context) {
    if (!isActive) return ActionRequired.none;

    final userType =
        Provider.of<Database>(context, listen: false).currentUser!.userType;
    if (userType == UserType.none) {
      throw const NotLoggedIn();
    }

    if (userType == UserType.student &&
        actionRequired == ActionRequired.fromStudent) {
      return ActionRequired.fromStudent;
    } else if (userType == UserType.teacher &&
        actionRequired == ActionRequired.fromTeacher) {
      return ActionRequired.fromTeacher;
    } else {
      return ActionRequired.none;
    }
  }

  bool get isAnswered =>
      isActive && actionRequired != ActionRequired.fromStudent;
  bool get hasAnswer => discussion.isNotEmpty;

  void addToDiscussion(Message message) => discussion.add(message);
}

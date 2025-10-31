import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/models/database.dart';
import 'package:mon_stage_en_images/common/models/discussion.dart';
import 'package:mon_stage_en_images/common/models/enum.dart';
import 'package:mon_stage_en_images/common/models/message.dart';
import 'package:provider/provider.dart';

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
  Answer.fromSerialized(super.map)
      : discussion = Discussion.fromSerialized(map?['discussion'] ?? {}),
        isActive = map?['isActive'],
        isValidated = map?['isValidated'],
        actionRequired = ActionRequired.values[map?['actionRequired']],
        createdById = map?['createdById'],
        studentId = map?['studentId'],
        super.fromSerialized();
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
        Provider.of<Database>(context, listen: false).currentUser?.userType ??
            UserType.none;
    if (userType == UserType.none) return ActionRequired.none;

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

class StudentAnswers extends ItemSerializable {
  final List<Answer> answers;

  StudentAnswers(this.answers, {required String studentId})
      : super(id: studentId);

  StudentAnswers.fromSerialized(map)
      : answers = (map as Map?)
                ?.values
                .where((e) => map?['id'] != e)
                .map((answer) => Answer.fromSerialized(
                    (answer as Map).cast<String, dynamic>()))
                .toList() ??
            [],
        super(id: map?['id']);

  @override
  Map<String, dynamic> serializedMap() =>
      {for (var e in answers) e.id: e.serialize()};
}

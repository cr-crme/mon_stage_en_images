import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:mon_stage_en_images/common/models/enum.dart';
import 'package:mon_stage_en_images/common/providers/all_answers.dart';

class Question extends ItemSerializableWithCreationTime {
  // Constructors and (de)serializer
  Question(
    this.text, {
    required this.section,
    required this.defaultTarget,
    super.id,
    super.creationTimeStamp,
    this.canBeDeleted = true,
  });
  Question.fromSerialized(super.map)
      : text = map?['text'],
        section = map?['section'],
        defaultTarget = Target.values[map?['defaultTarget']],
        canBeDeleted = map?['canBeDeleted'] ?? false,
        super.fromSerialized();
  Question copyWith({
    String? text,
    int? section,
    Target? defaultTarget,
    String? id,
    int? creationTimeStamp,
  }) {
    text ??= this.text;
    section ??= this.section;
    defaultTarget ??= this.defaultTarget;
    id ??= this.id;
    creationTimeStamp ??= this.creationTimeStamp;
    return Question(
      text,
      section: section,
      defaultTarget: defaultTarget,
      canBeDeleted: canBeDeleted,
      id: id,
      creationTimeStamp: creationTimeStamp,
    );
  }

  Question deserializeItem(map) => Question.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() => {
        'text': text,
        'section': section,
        'defaultTarget': defaultTarget.index,
        'canBeDeleted': canBeDeleted,
      };

  bool hasAtLeastOneAnswer({required AllAnswers answers}) =>
      answers.filter(questionIds: [id], isAnswered: true).isNotEmpty;

  // Attributes and methods
  final String text;
  final int section;
  final Target defaultTarget;
  final bool canBeDeleted;
}

import 'package:enhanced_containers/item_serializable_with_creation_time.dart';

import '../../common/models/enum.dart';

class Question extends ItemSerializableWithCreationTime {
  // Constructors and (de)serializer
  Question(
    this.text, {
    required this.section,
    required this.defaultTarget,
    super.id,
    super.creationTimeStamp,
  });
  Question.fromSerialized(map)
      : text = map['text'],
        section = map['section'],
        defaultTarget = Target.values[map['defaultTarget']],
        super.fromSerialized(map);
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
      id: id,
      creationTimeStamp: creationTimeStamp,
    );
  }

  Question deserializeItem(map) {
    return Question.fromSerialized(map);
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'text': text,
      'section': section,
      'defaultTarget': defaultTarget.index,
    };
  }

  // Attributes and methods
  final String text;
  final int section;
  final Target defaultTarget;
}

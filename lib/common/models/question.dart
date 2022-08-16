import 'package:defi_photo/crcrme_enhanced_containers/lib/item_serializable.dart';

import '../../common/models/enum.dart';

class Question extends ItemSerializable {
  // Constructors and (de)serializer
  Question(
    this.text, {
    required this.section,
    required this.defaultTarget,
    String? id,
    int? creationTime,
  }) : super(id: id, creationTime: creationTime);
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
    int? creationTime,
  }) {
    text ??= this.text;
    section ??= this.section;
    defaultTarget ??= this.defaultTarget;
    id ??= this.id;
    creationTime ??= this.creationTime;
    return Question(
      text,
      section: section,
      defaultTarget: defaultTarget,
      id: id,
      creationTime: creationTime,
    );
  }

  @override
  ItemSerializable deserializeItem(map) {
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

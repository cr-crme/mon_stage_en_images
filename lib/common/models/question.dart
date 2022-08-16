import 'package:defi_photo/crcrme_enhanced_containers/lib/item_serializable.dart';

import '../../common/models/enum.dart';

class Question extends ItemSerializable {
  // Constructors and (de)serializer
  Question(
    this.text, {
    required this.section,
    required this.defaultTarget,
    id,
  }) : super(id: id);
  Question.fromSerialized(map)
      : text = map['text'],
        section = map['section'],
        defaultTarget = Target.values[map['defaultTarget']],
        super.fromSerialized(map);
  Question copyWith({text, section, defaultTarget, id}) {
    text ??= this.text;
    section ??= this.section;
    defaultTarget ??= this.defaultTarget;
    id ??= this.id;
    return Question(
      text,
      section: section,
      defaultTarget: defaultTarget,
      id: id,
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

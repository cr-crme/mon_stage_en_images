import '../../misc/custom_list/item_serializable.dart';

class Question extends ItemSerializable {
  final String title;

  Question(this.title);
  Question.fromSerialized(Map<String, dynamic> map)
      : title = map['question'],
        super.fromSerialized(map);

  @override
  ItemSerializable deserializeItem(Map<String, dynamic> map) {
    return Question(map['question']);
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'question': title,
    };
  }
}

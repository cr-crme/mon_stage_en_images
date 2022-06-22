import '../../misc/custom_containers/item_serializable.dart';

class Discussion extends ItemSerializable {
  // Constructors and (de)serializer
  Discussion({required this.name, required this.text});
  Discussion.fromSerialized(Map<String, dynamic> map)
      : name = map['name'],
        text = map['text'],
        super.fromSerialized(map);
  @override
  ItemSerializable deserializeItem(Map<String, dynamic> map) =>
      Discussion.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'name': name,
      'text': text,
    };
  }

  // Attributes and methods
  final String name;
  final String text;
}

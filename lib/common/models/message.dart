import '../../misc/custom_containers/item_serializable.dart';

class Message extends ItemSerializable {
  // Constructors and (de)serializer
  Message({required this.name, required this.text, id}) : super(id: id);
  Message.fromSerialized(Map<String, dynamic> map)
      : name = map['name'],
        text = map['text'],
        super.fromSerialized(map);
  @override
  ItemSerializable deserializeItem(Map<String, dynamic> map) =>
      Message.fromSerialized(map);

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

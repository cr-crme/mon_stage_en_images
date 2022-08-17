import 'package:defi_photo/crcrme_enhanced_containers/lib/timed_item_serializable.dart';

class Message extends TimedItemSerializable {
  // Constructors and (de)serializer
  Message({
    required this.name,
    required this.text,
    this.isPhotoUrl = false,
    String? id,
    int? creationTimeStamp,
  }) : super(id: id, creationTimeStamp: creationTimeStamp);
  Message.fromSerialized(map)
      : name = map['name'],
        text = map['text'],
        isPhotoUrl = map['isPhotoUrl'],
        super.fromSerialized(map);
  @override
  TimedItemSerializable deserializeItem(map) => Message.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'name': name,
      'text': text,
      'isPhotoUrl': isPhotoUrl,
    };
  }

  // Attributes and methods
  final String name;
  final String text;
  final bool isPhotoUrl;
}

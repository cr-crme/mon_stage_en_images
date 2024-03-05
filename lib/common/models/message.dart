import 'package:enhanced_containers/enhanced_containers.dart';

class Message extends ItemSerializableWithCreationTime {
  // Constructors and (de)serializer
  Message({
    required this.name,
    required this.text,
    this.isPhotoUrl = false,
    super.id,
    super.creationTimeStamp,
    required this.creatorId,
  });
  Message.fromSerialized(super.map)
      : name = map['name'],
        text = map['text'],
        isPhotoUrl = map['isPhotoUrl'],
        creatorId = map['creatorId'],
        super.fromSerialized();

  Message deserializeItem(map) => Message.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'name': name,
      'text': text,
      'isPhotoUrl': isPhotoUrl,
      'creatorId': creatorId
    };
  }

  // Attributes and methods
  final String name;
  final String text;
  final bool isPhotoUrl;
  final String creatorId;
}

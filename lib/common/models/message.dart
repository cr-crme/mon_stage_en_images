import 'package:defi_photo/crcrme_enhanced_containers/lib/creation_time_item_serializable.dart';

class Message extends CreationTimeItemSerializable {
  // Constructors and (de)serializer
  Message({
    required this.name,
    required this.text,
    this.isPhotoUrl = false,
    String? id,
    int? creationTimeStamp,
    required this.creatorId,
  }) : super(id: id, creationTimeStamp: creationTimeStamp);
  Message.fromSerialized(map)
      : name = map['name'],
        text = map['text'],
        isPhotoUrl = map['isPhotoUrl'],
        creatorId = map['creatorId'],
        super.fromSerialized(map);
  @override
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

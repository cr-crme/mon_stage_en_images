import 'package:defi_photo/crcrme_enhanced_containers/lib/item_serializable.dart';

class Company extends ItemSerializable {
  Company({required this.name, String? id, int? creationTime})
      : super(id: id, creationTime: creationTime);
  Company copyWith({String? name, String? id, int? creationTime}) {
    name ??= this.name;
    id ??= this.id;
    creationTime ??= this.creationTime;
    return Company(name: name, id: id, creationTime: creationTime);
  }

  Company.fromSerialized(map)
      : name = map['name'] ?? 'No name',
        super.fromSerialized(map);

  final String name;

  @override
  String toString() => name.toString();

  @override
  Company deserializeItem(map) {
    return Company.fromSerialized(map);
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {'name': name};
  }
}

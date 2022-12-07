import 'package:enhanced_containers/enhanced_containers.dart';

class Company extends ItemSerializable {
  Company({required this.name, super.id});
  Company copyWith({String? name, String? id}) {
    name ??= this.name;
    id ??= this.id;
    return Company(name: name, id: id);
  }

  Company.fromSerialized(map)
      : name = map['name'] ?? 'No name',
        super.fromSerialized(map);

  final String name;

  @override
  String toString() => name.toString();

  Company deserializeItem(map) {
    return Company.fromSerialized(map);
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {'name': name};
  }
}

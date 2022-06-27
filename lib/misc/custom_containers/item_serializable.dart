import 'dart:math';

abstract class ItemSerializable {
  static int _counter = 0;
  final String id;

  ItemSerializable({id}) : id = id ?? _counter.toString() {
    _counter += 1;
  }
  ItemSerializable.fromSerialized(Map<String, dynamic> map)
      : id = map['id'] ?? Random().hashCode.toString();

  Map<String, dynamic> serializedMap();
  Map<String, dynamic> serialize() {
    var out = serializedMap();
    out['id'] = id;
    return out;
  }

  ItemSerializable deserializeItem(Map<String, dynamic> map);
}

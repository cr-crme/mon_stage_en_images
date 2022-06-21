import 'dart:math';

abstract class ProvidedItem {
  static int _counter = 0;
  late final String id;

  ProvidedItem({id}) : id = _counter.toString() {
    _counter += 1;
  }
  ProvidedItem.fromSerialized(Map<String, dynamic> map)
      : id = map['id'] ?? Random().hashCode.toString();

  Map<String, dynamic> serializedMap();
  Map<String, dynamic> serialize() {
    var out = serializedMap();
    out['id'] = id;
    return out;
  }

  ProvidedItem deserializeItem(Map<String, dynamic> map);
}

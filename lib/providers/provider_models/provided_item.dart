import 'dart:math';

abstract class ProvidedItem {
  late final String id;

  ProvidedItem({id}) : id = id ?? Random().hashCode.toString();
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

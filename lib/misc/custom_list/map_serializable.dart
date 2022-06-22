import './item_serializable.dart';

bool isInteger(num value) => (value % 1) == 0;

class TypeException implements Exception {
  final String message;

  const TypeException(this.message);
}

abstract class MapSerializable<T> {
  MapSerializable();
  MapSerializable.fromSerialized(Map<String, dynamic> map) {
    deserialize(map);
  }

  Map<String, dynamic> serialize() {
    final serializedItem = {};
    items.forEach((key, element) =>
        serializedItem[key] = (element as ItemSerializable).serialize());
    return {
      'items': serializedItem,
    };
  }

  T deserializeItem(Map<String, dynamic> map);

  void deserialize(Map<String, dynamic> map) {
    items.clear();
    map['items']!.forEach((key, element) {
      items[key] = deserializeItem(element);
    });
  }

  final Map<String, T> items = {};

  void add(String key, T item) {
    items[key] = item;
  }

  T? operator [](key) {
    return items[key];
  }

  void remove(key) {
    items.remove(key);
  }

  void clear() {
    items.clear();
  }

  int get length => items.length;
}

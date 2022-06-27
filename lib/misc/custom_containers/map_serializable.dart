import './item_serializable.dart';

bool isInteger(num value) => (value % 1) == 0;

class TypeException implements Exception {
  final String message;

  const TypeException(this.message);
}

abstract class MapSerializable<T> extends Iterable<MapEntry<String, T>> {
  // Constructors and (de)serializer
  final Map<String, T> items = {};
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

  // Iterator
  @override
  Iterator<MapEntry<String, T>> get iterator =>
      items.entries.iterator; // Todo make a copy here

  // Attributes and methods
  void add(key, T item) => this[key] = item;
  void replace(key, T item) => this[key] = item;

  void operator []=(key, T item) {
    if (key is ItemSerializable) {
      items[key.id] = item;
    } else {
      items[key] = item;
    }
  }

  T? operator [](key) {
    if (key is ItemSerializable) {
      return items[key.id];
    } else {
      return items[key];
    }
  }

  void remove(key) {
    items.remove(key);
  }

  void clear() {
    items.clear();
  }
}

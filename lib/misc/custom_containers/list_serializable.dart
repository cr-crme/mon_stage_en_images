import './item_serializable.dart';

bool isInteger(num value) => (value % 1) == 0;

class TypeException implements Exception {
  final String message;

  const TypeException(this.message);
}

abstract class ListSerializable<T> extends Iterable<T> {
  // Constructors and (de)serializer
  ListSerializable();
  ListSerializable.fromSerialized(Map<String, dynamic> map) {
    deserialize(map);
  }

  Map<String, dynamic> serialize() {
    final serializedItem = [];
    for (var element in items as List<ItemSerializable>) {
      serializedItem.add(element.serialize());
    }
    return {
      'items': serializedItem,
    };
  }

  T deserializeItem(map);

  void deserialize(Map<String, dynamic> map) {
    items.clear();
    for (var element in map['items']) {
      items.add(deserializeItem(element));
    }
  }

  // Iterator
  @override
  Iterator<T> get iterator => items.iterator; // Todo make a copy here

  // Attributes and methods
  final List<T> items = [];

  void add(T item) {
    items.add(item);
  }

  void replace(T item, {bool notify = true}) {
    items[_getIndex(item)] = item;
  }

  @override
  bool contains(Object? element) {
    if (element is String) {
      return items.any((item) => (item as ItemSerializable).id == element);
    } else {
      return items.contains(element);
    }
  }

  operator []=(value, T item) {
    items[_getIndex(value)] = item;
  }

  T operator [](value) {
    return items[_getIndex(value)];
  }

  void remove(value) {
    items.removeAt(_getIndex(value));
  }

  void clear() {
    items.clear();
  }

  int indexWhere(bool Function(T element) test, [int start = 0]) {
    return items.indexWhere(test, start);
  }

  int _getIndex(value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      return items
          .indexWhere((element) => (element as ItemSerializable).id == value);
    } else if (value is ItemSerializable) {
      return _getIndex(value.id);
    } else {
      throw const TypeException(
          'Wrong type for getting an element of the provided list');
    }
  }
}

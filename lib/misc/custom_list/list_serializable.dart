import './item_serializable.dart';

bool isInteger(num value) => (value % 1) == 0;

class TypeException implements Exception {
  final String message;

  const TypeException(this.message);
}

abstract class ListSerializable<T> {
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

  final List<T> items = [];

  int get length => items.length;

  void add(T item) {
    items.add(item);
  }

  T? operator [](value) {
    return items[_getIndex(value)];
  }

  void remove(value) {
    items.removeAt(_getIndex(value));
  }

  void clear() {
    items.clear();
  }

  int _getIndex(value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      return items
          .indexWhere((element) => (element as ItemSerializable).id == value);
    } else {
      throw const TypeException(
          'Wrong type for getting an element of the provided list');
    }
  }
}

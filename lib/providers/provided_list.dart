import 'package:flutter/foundation.dart';

import './provider_models/exceptions.dart';
import './provider_models/provided_item.dart';

bool isInteger(num value) => (value % 1) == 0;

abstract class ProvidedList<T> with ChangeNotifier {
  final List<T> items = [];

  void add(T item, {bool notify = true}) {
    items.add(item);
    if (notify) notifyListeners();
  }

  T? operator [](value) {
    return items[_getIndex(value)];
  }

  void remove(value, {bool notify = true}) {
    items.removeAt(_getIndex(value));
    if (notify) notifyListeners();
  }

  void clear() {
    items.clear();
  }

  int _getIndex(value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      return items
          .indexWhere((element) => (element as ProvidedItem).id == value);
    } else {
      throw const TypeException(
          'Wrong type for getting an element of the provided list');
    }
  }

  int get length => items.length;

  Map<String, dynamic> serialize() {
    final serializedItem = [];
    for (var element in items as List<ProvidedItem>) {
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
}

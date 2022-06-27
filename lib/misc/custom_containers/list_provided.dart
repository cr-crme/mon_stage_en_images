import 'package:flutter/foundation.dart';

import './list_serializable.dart';

abstract class ListProvided<T> extends ListSerializable<T> with ChangeNotifier {
  ListProvided() : super();
  ListProvided.fromSerialized(Map<String, dynamic> map)
      : super.fromSerialized(map);

  @override
  void add(T item, {bool notify = true}) {
    super.add(item);

    if (notify) notifyListeners();
  }

  @override
  void replace(T item, {bool notify = true}) {
    super.replace(item);
    if (notify) notifyListeners();
  }

  @override
  operator []=(value, T item) {
    super[value] = item;
    notifyListeners();
  }

  @override
  void remove(value, {bool notify = true}) {
    super.remove(value);
    if (notify) notifyListeners();
  }
}

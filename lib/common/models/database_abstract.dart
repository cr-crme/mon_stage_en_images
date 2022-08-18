import 'package:defi_photo/crcrme_enhanced_containers/lib/item_serializable.dart';

import './enum.dart';

abstract class DataBaseAbstract {
  Future<void> initialize();

  Future<LoginStatus> login(String email, String password);

  Future<void> send(String path, ItemSerializable data);
  Future<T> get<T>(String path);
}

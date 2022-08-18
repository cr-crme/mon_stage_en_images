import 'package:defi_photo/crcrme_enhanced_containers/lib/item_serializable.dart';

import './enum.dart';
import './user.dart';

abstract class DataBaseAbstract {
  Future<void> initialize();

  Future<LoginStatus> login(String email, String password);

  Future<void> send(String path, ItemSerializable data);
  Future<T> get<T>(String path);
  Future<User> getUser(String path);
}

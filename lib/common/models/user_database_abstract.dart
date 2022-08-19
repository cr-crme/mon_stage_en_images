import './enum.dart';
import './user.dart';

abstract class UserDataBaseAbstract {
  String pathToAllUsers = 'users';
  Future<void> initialize();

  Future<LoginStatus> login(String email, String password);

  Future<void> send(User user);
  Future<User?> getUser(String email);
}

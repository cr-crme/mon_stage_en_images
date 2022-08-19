import './enum.dart';
import './user.dart';

abstract class UserDataBaseAbstract {
  String pathToAllUsers = 'users';
  Future<void> initialize();

  Future<LoginStatus> login(String email, String password);

  Future<LoginStatus> updatePassword(User user, String newPassword);
  Future<LoginStatus> send({required User user, required String password});
  Future<User?> getUser(String email);
}

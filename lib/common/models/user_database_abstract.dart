import './enum.dart';
import './user.dart';

abstract class UserDataBaseAbstract {
  String pathToAllUsers = 'users';
  Future<void> initialize();

  Future<LoginStatus> login(String email, String password);

  Future<LoginStatus> updatePassword(User user, String newPassword);
  Future<LoginStatus> addUser({required User user, required String password});
  Future<LoginStatus> modifyUser({required User user});
  Future<LoginStatus> deleteUser({required String email});
  Future<User?> getUser(String email);
}

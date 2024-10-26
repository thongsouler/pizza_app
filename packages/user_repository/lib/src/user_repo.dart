import 'models/models.dart';

abstract class UserRepository {
  Stream<MyUser?> get user;

  Future<MyUser> signUp(MyUser myUser, String password);

  Future<void> setUserData(MyUser user);

  Future<void> signIn(MyUser userData);

  Future<void> logOut();

  Future<void> setPlace(String userId, String place) async {}
}

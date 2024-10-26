import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:rxdart/rxdart.dart';
import 'package:user_repository/user_repository.dart';
import 'package:pizza_app/globals.dart' as globals;

class FirebaseUserRepo implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  final usersCollection = FirebaseFirestore.instance.collection('users');

  FirebaseUserRepo({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<MyUser?> get user {
    return _firebaseAuth.authStateChanges().flatMap((firebaseUser) async* {
      if (firebaseUser == null) {
        yield MyUser.empty;
      } else {
        yield MyUser(
          userId: firebaseUser.uid,
          idcode: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'Anonymous',
        );
      }
    });
  }

  @override
  Future<void> signIn(MyUser userData) async {
    try {
      await _firebaseAuth.signInAnonymously();
      String userId = DateFormat('ddMMMyyyy_HH:mm').format(DateTime.now());
      var user = MyUser(
        userId: userId,
        name: userData.name,
        idcode: userData.idcode,
        address: userData.address,
      );
      await setUserData(user);
      globals.currentUser = user;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
      // UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(
      //     email: myUser.email, password: password);

      // myUser.userId = user.user!.uid;
      return myUser;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> setUserData(MyUser myUser) async {
    try {
      await usersCollection
          .doc(myUser.userId)
          .set(myUser.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> setPlace(String userId, String place) async {
    try {
      await usersCollection.doc(userId).update({
        'toPlace': place,
      });
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

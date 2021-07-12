import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keep_on_moving/model/UserModel.dart';
import 'package:keep_on_moving/screens/ToastMessage.dart';
import 'package:keep_on_moving/services/database.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user based on FirebaseUser
  UserModel? _userFromFirebaseUser(User? user) {
    return user != null ? UserModel(name: "", imagePath: "", groups: [], email: "", currentGroup: "") : null;
  }

  // auth change user stream
  Stream<UserModel?> get user{
    return _auth.authStateChanges().map((User? user) => _userFromFirebaseUser(user));
  }

  // GET UID
  String? getCurrentUID() {
    return _auth.currentUser!.uid;
  }

  // GET CURRENT USER
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future registerWithEmail(String name, String email, String password) async {
    try {

      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      UserModel? createdUser = _userFromFirebaseUser(user!);
      createdUser!.name = name;
      createdUser.email = email;

      await DatabaseService(uid: user.uid).updateUserData(name, "", []);

      await DatabaseService().addGroupToUser("12345");
      await DatabaseService().addGroupMember("12345");
      await DatabaseService().updateCurrentGroup("YDHrz0646MvXzUmxIrYk");
      
      // show toast message if it was successful (no exception was thrown)
      //ToastMessage().popUp("Der Benutzer "+name+" wurde erfolgreich erstellt!");

      return createdUser;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }



  Future loginWithUser(String userName, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: userName, password: password);

      User? user = result.user;
      UserModel? createdUser = _userFromFirebaseUser(user!);
      return createdUser;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future logOut() async{
    try{
      return await _auth.signOut();
    }
    catch(e){
      print(e.toString());
      return null;
    }
  }


}

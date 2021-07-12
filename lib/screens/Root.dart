import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keep_on_moving/screens/Authentification.dart';
import 'package:keep_on_moving/screens/HomeScreen.dart';
import 'package:keep_on_moving/services/auth.dart';
import 'package:keep_on_moving/services/database.dart';
import 'package:provider/provider.dart';
import 'package:keep_on_moving/model/UserModel.dart';

import 'LoginScreen.dart';

class Root extends StatefulWidget{
  @override
  _Root createState() => _Root();
}

class _Root extends State<Root> {
  @override
  Widget build(BuildContext context){
    //final user1 = Provider.of<User?>(context);
    final user = AuthService().getCurrentUser();
/*    var result = DatabaseService().getGroups();
    String argument;*/

    if (user == null){
      return Authenticate();
    } else {
/*      if (result == null || result.isEmpty) {
        argument = "Keine Gruppe gewählt";
      }
      else {
        argument = result[0];
      }*/
      return HomeScreen();
    }
  }
}
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keep_on_moving/model/UserModel.dart';
import 'package:keep_on_moving/services/auth.dart';
import 'package:keep_on_moving/services/database.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileWidget extends StatefulWidget {

  final String username;
  final String profileImage;
  final Map<String, dynamic> group;

  const ProfileWidget({
    Key? key,
    required this.username,
    required this.profileImage,
    required this.group,
  }) : super(key: key);

  @override
  _ProfileWidget createState() => _ProfileWidget();

}

class _ProfileWidget extends State<ProfileWidget>{

  var uid = AuthService().getCurrentUID();



  @override
  Widget build(BuildContext context) {

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: buildImage(context),
          ),
          const SizedBox(width: 25),
          Center(
            child: Container(
              height: 120,
              alignment: Alignment.center,
              child: buildProfile(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfile(BuildContext context) {

    var score = widget.group['points'][uid]['score'];

    return Column(
      children: [
        Flexible(
          flex: 3,
          child: Text(
            'Welcome',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
          ),
        ),
        Flexible(
            flex: 3,
            child: buildName(context)),
        Flexible(child: SizedBox(height: 4)),
        Flexible(
          flex: 2,
          child: Text(
            widget.group['groupName'] ?? 'kein Name',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
        Flexible(child: SizedBox(height: 4)),
        Flexible(
          flex: 3,
          child: Text(
            score.toString(),
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        )
      ],
    );
  }

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );

  Widget buildName(BuildContext context) {
    return Text(
              widget.username,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
          );
  }


  Widget buildImage(BuildContext context) {

    Image img = Image.asset("assets/images/profile_dummy.png");
    if (widget.profileImage.isNotEmpty) img = Image.network(widget.profileImage);


        return ClipOval(
          child: Material(
            color: Colors.transparent,
            child: Ink.image(
              image: img.image,
              fit: BoxFit.cover,
              width: 130,
              height: 130,
              //padding: EdgeInsets.all(24),
            ),
          ),
        );
  }
}

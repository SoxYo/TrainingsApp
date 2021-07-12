import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keep_on_moving/model/FirebaseFile.dart';
import 'package:keep_on_moving/model/GroupModel.dart';
import 'package:keep_on_moving/model/UserModel.dart';
import 'package:keep_on_moving/services/auth.dart';
import 'package:keep_on_moving/services/database.dart';
import 'package:keep_on_moving/user_preferences/UserPreferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class Profile extends StatefulWidget{
  @override
  _Profile createState() => _Profile();
}

class _Profile extends State<Profile>{

  String userName = "";
  final user = AuthService().getCurrentUser();
  var group = new Group(gid: 'SportyGirls', imagePath: 'assets/images/women_running.jpg');

  UploadTask? task;
  File? file;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.single.path!;

    setState(() => file = File(path));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.home), onPressed: () { Navigator.pushReplacementNamed(context, 'HomeScreen'); },),
        centerTitle: true,
        title: Text('Mein Profil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height:20),
            Center(
              child: buildImage(context),
            ),
            TextButton(
                onPressed: (){
                  uploadProfilePic(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Profilbild ändern'),
                    Icon(Icons.edit, size: 15),
                  ]
                )
            ),
            SizedBox(height:20),
            Text(
              'Benutzername',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height:10),
            buildName(context),
            SizedBox(height: 20),
            Text(
              'Email-Adresse',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height:10),
            Text(
              user!.email.toString(),
            ),
          ],
        ),
      )
    );
  }


  Widget buildGroup(Group group) {

    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 10),
            ClipOval(
              child: Material(
                color: Colors.transparent,
                child: Ink.image(
                  image: AssetImage(group.imagePath.toString()),
                  fit: BoxFit.cover,
                  width: 130,
                  height: 130,
                  //padding: EdgeInsets.all(24),
                ),
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
        SizedBox(height:5),
        Text(group.gid),
      ],
    );
  }

  Future<void> uploadProfilePic(BuildContext context) {

    final fileName = file != null ? basename(file!.path) : 'No File Selected';

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Bitte wählen Sie ein Profilbild aus'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Datei:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold
                      )),
                  SizedBox(height: 30),
                  IconButton(
                      onPressed: () {
                        selectFile();
                      },
                      icon: Icon(Icons.upload_file)),
                  Text(
                    fileName,
                  ),
                  task != null ? buildUploadStatus(task!) : Container(),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: const Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () async {
                  await uploadFile();
                  Navigator.pushNamed(context, 'HomeScreen');
                },
                child: const Text('Speichern'),
              ),
            ],
          );
        });
  }

  Future uploadFile() async {
    if (file == null) return;

    final fileName = basename(file!.path);
    final destination = 'profile_pics/$fileName';

    task = DatabaseService.uploadFile(destination, file!);
    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    DatabaseService().updateImagePath(urlDownload);

    print('Download-Link: $urlDownload');
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
    stream: task.snapshotEvents,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final snap = snapshot.data!;
        final progress = snap.bytesTransferred / snap.totalBytes;
        final percentage = (progress * 100).toStringAsFixed(2);

        return Text(
          '$percentage %',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        );
      } else {
        return Container();
      }
    },
  );

  getCurrentUserName() async {
    String? uid = AuthService().getCurrentUID();
    DocumentSnapshot ds = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    userName = ds.get('name');
  }

  Widget buildName(BuildContext context) {
    return new FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
      builder: (_, snapshot) {
        if (snapshot.hasError) return Text ('Error = ${snapshot.error}');

        if (snapshot.hasData) {
          var data = snapshot.data!.data();
          var value = data!['name']; // <-- Your value
          return Text(value);
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }


  Widget buildImage(BuildContext context) {

    Image img = Image.asset("assets/images/profile_dummy.png");;

    return new FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
      builder: (_, snapshot) {
        if (snapshot.hasError) {
        }
        if (snapshot.hasData) {
          var data = snapshot.data!.data();
          var value = data!['imagePath'];
          if(value != "") img = Image.network(value);
        }
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
      },
    );
  }
}
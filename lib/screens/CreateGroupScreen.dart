import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keep_on_moving/screens/ToastMessage.dart';
import 'package:keep_on_moving/services/auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:keep_on_moving/services/database.dart';
import 'package:path/path.dart';

class CreateGroup extends StatefulWidget {
  @override
  _CreateGroup createState() => _CreateGroup();
}

class _CreateGroup extends State<CreateGroup> {

  var _image;
  String groupName = "";

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

    final fileName = file != null ? basename(file!.path) : 'No File Selected';

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.home), onPressed: () { Navigator.pushReplacementNamed(context, 'HomeScreen'); },),
        ),
        body: ListView(
          children: [
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Gruppenname',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              keyboardType: TextInputType.name,
              autocorrect: false,
              validator: (value) =>
                  value!.isEmpty ? 'Gruppenname eingeben' : null,
              onChanged: (value) {
                groupName = value;
              },
              decoration: InputDecoration(
                  focusColor: Colors.pink,
                  labelText: 'Gruppenname eingeben',
                  border: OutlineInputBorder()),
            ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Gruppenbild',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
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
            TextButton(
                onPressed: () async {

                  var code;
                  bool codeExists = false;

                  do {
                    // get random ID
                    code = getRandomString(5);
                    // get all groups with that specific ID
                    var result = await FirebaseFirestore.instance.collection('groups')
                        .where('groupId', isEqualTo: code).get();
                    // put groups into a list
                    final List < DocumentSnapshot > documents = result.docs;
                    // check if a group with that ID already exists
                    if (documents.length > 0) codeExists = true;

                  } while(codeExists);

                  uploadFile(code);
                  ToastMessage.popUp("Gruppe wurde erfolgreich erstellt!");
                  Navigator.pushNamed(context, 'GroupListScreen');

                  /*try {
                    var result = await FirebaseFirestore.instance
                        .collection('groups')
                        .add({
                      "name": groupName,
                      "admin": FirebaseAuth.instance.currentUser?.uid,
                      "shareCode": code,
                      // "videos": [],
                    });

                    Navigator.pushNamed(context, 'HomeScreen', arguments: result.id);
                  } on FirebaseException catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Failed with ${error.message}'),
                    ));
                  }*/
                },
                child: Text('Gruppe erstellen'))
          ],
        ));
  }

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));


  Future uploadFile(String groupId) async {

    if (file == null) return;

    // remove the path of the picked file to get the filename only
    final fileName = basename(file!.path);
    final destination = 'group_pics/$fileName';

    // upload file in cloud storage
    task = DatabaseService.uploadFile(destination, file!);
    setState(() {});

    if (task == null) return;

    // get the url from cloud storage to save it in the database
    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    // save the new group data in the database, based on current user
    var id = AuthService().getCurrentUID();
    String groupDocId = await DatabaseService().createGroup(id!, groupName, groupId, urlDownload);
    DatabaseService().updateCurrentGroup(groupDocId);
    DatabaseService().addGroupMember(groupId);
    DatabaseService().addGroupToUser(groupId);

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

}

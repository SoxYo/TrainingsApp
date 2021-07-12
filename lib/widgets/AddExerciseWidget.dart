import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keep_on_moving/screens/ToastMessage.dart';
import 'package:keep_on_moving/services/database.dart';
import 'package:path/path.dart';

class AddExercise extends StatefulWidget {

  final String category;
  AddExercise({required this.category});

  @override
  _AddExercise createState() => _AddExercise();

}

class _AddExercise extends State<AddExercise> {

  String title = "";
  String videoUrl = "";
  String thumbnailUrl = "";

  var _image;

  UploadTask? task_pic;
  UploadTask? task_vid;
  File? file_pic;
  File? file_vid;

  Future selectImage() async {

    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.single.path!;

    setState(() => file_pic = File(path));
  }

  Future selectVideo() async {

    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.single.path!;

    setState(() => file_vid = File(path));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      child: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: CircleBorder(), primary: Colors.pink[100]),
          child: Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: Text(
              '+',
              style: TextStyle(fontSize: 12),
            ),
          ),
          onPressed: () => createExercise(context),
        ),
      ),
    );
  }

  Future<void> createExercise(BuildContext context) {

    final fileNamePic = file_pic != null ? basename(file_pic!.path) : 'No File Selected';
    final fileNameVid = file_vid != null ? basename(file_vid!.path) : 'No File Selected';

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Neue Übung hinzufügen'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Kategorie:  ' + widget.category,
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  )),
                  SizedBox(height: 30),
                  Text('Name: '),
                  SizedBox(height: 5),
                  TextField(
                    onChanged: (value) {
                      title = value;
                    },
                  ),
                  SizedBox(height: 30),
                  Text('Video: '),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Flexible(
                          flex: 2,
                          child: Container(
                            height: 30,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                              ),
                            ),
                          )),
                      Flexible(
                          child: IconButton(
                              onPressed: () {
                                selectVideo();
                              },
                              icon: Icon(Icons.upload_file))),
                      Flexible(
                        child: Text(
                          fileNameVid
                        ),
                      ),
                      task_vid != null ? buildUploadStatus(task_vid!) : Container(),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text('Thumbnail: '),
                  SizedBox(height: 5),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Flexible(
                          flex: 2,
                          child: Container(
                            height: 30,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                              ),
                            ),
                          )),
                      Flexible(
                          child: IconButton(
                              onPressed: () {
                                selectImage();
                              },
                              icon: Icon(Icons.upload_file))),
                      Flexible(
                        child: Text(
                            fileNamePic
                        ),
                      ),
                      task_pic != null ? buildUploadStatus(task_pic!) : Container(),
                    ],
                  ),
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
                  await uploadImage();
                  await uploadVideo();
                  await DatabaseService().createExercise(title, widget.category, thumbnailUrl, videoUrl);
                  ToastMessage.popUp("Übung wurde angelegt!");
                  Navigator.pushNamed(context, 'HomeScreen');
                },
                child: const Text('Speichern'),
              ),
            ],
          );
        });
  }


  Future uploadImage() async {
    if (file_pic == null) return;

    final fileName = basename(file_pic!.path);
    final destination = 'thumbnails/$fileName';

    task_pic = DatabaseService.uploadFile(destination, file_pic!)!;
    setState(() {});

    if (task_pic == null) return;

    final snapshot = await task_pic!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    thumbnailUrl = urlDownload;
    print('thumbnail: '+thumbnailUrl);
  }


  Future uploadVideo() async {
    if (file_vid == null) return;

    final fileName = basename(file_vid!.path);
    final destination = 'videos/$fileName';

    task_vid = DatabaseService.uploadFile(destination, file_vid!);
    setState(() {});

    if (task_vid == null) return;

    final snapshot = await task_vid!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    videoUrl = urlDownload;
    print('video: '+videoUrl);
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

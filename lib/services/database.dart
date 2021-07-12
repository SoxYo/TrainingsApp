import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:keep_on_moving/model/FirebaseFile.dart';
import 'package:keep_on_moving/services/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  final String? uid;

  DatabaseService({this.uid});

  // collection reference
  final CollectionReference<Map<String, dynamic>> userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference<Map<String, dynamic>> groupCollection =
      FirebaseFirestore.instance.collection('groups');
  final CollectionReference<Map<String, dynamic>> pointCollection =
  FirebaseFirestore.instance.collection('points');



  Future updateUserData(String name, String imagePath, List groups) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'imagePath': imagePath,
      'groups': [],
      'currentGroup': ""
    });
  }

  Future<String> getCurrentUserName() async {
    String? uid = AuthService().getCurrentUID();
    DocumentSnapshot data = await userCollection.doc(uid).get();
    return data['name'];
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    String? uid = AuthService().getCurrentUID();
    var data = await userCollection.doc(uid).get();
    return data.data() ?? {};
  }

  getUserName() async {
    String username = await getCurrentUserName();
    return username;
  }

  Future<String> getUserByID(String userId) async {
    var data = await userCollection.doc(userId).get();
    return data['name'].toString();
  }

  Future<String> getImageByID(String userId) async {
    var data = await userCollection.doc(userId).get();
    return data['imagePath'].toString();
  }

  String getUserImagePath() {
    String? uid = AuthService().getCurrentUID();
    String imagePath = "";
    userCollection
        .doc(uid)
        .get()
        .then((value) => imagePath = value.get(["imagePath"]));
    return imagePath;
  }

  Future updateImagePath(String imagePath) async {
    final userID = AuthService().getCurrentUID();
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userID)
        .update({"imagePath": imagePath});
  }

  Future updateCurrentGroup(String groupId) async {
    final userID = AuthService().getCurrentUID();
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userID)
        .update({"currentGroup": groupId});
  }

  Future<String> getCurrentGroup() async {
    final userID = AuthService().getCurrentUID();
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userID)
        .get()
        .then((value) => value.get('currentGroup').toString());
  }

  Future<Map<String, dynamic>?> getGroup(String groupId) async {
    return await FirebaseFirestore.instance
        .collection("groups")
        .doc(groupId)
        .get()
        .then((value) => value.data());
  }

  Future getPointList(String groupId) async {
    Map<String, dynamic> list = {};
    var data = await FirebaseFirestore.instance
        .collection("groups")
        .doc(groupId)
        .get()
        .then((value) => value.get('points'));
    return data;
    //data.forEach((k, v) => list.map((key, value) => null))
  }

  Future<List<String>> getMembers(groupId) async {
    return await groupCollection.doc(groupId).get().then((value) => value.get('members'));
  }

  Future createExercise(String title, String category, String thumbnailUrl,
      String videoUrl) async {
    var groupId = await getCurrentGroup();
    print(groupId);
    return await groupCollection.doc(groupId).get().then((querySnapshot) {
      querySnapshot.reference.update({
        "exercises": FieldValue.arrayUnion([
          {
            'title': title,
            'category': category,
            'thumbnail': thumbnailUrl,
            'video': videoUrl
          }
        ])
      });
    });
  }

  Future addPoints(int points) async {
    // determine the current group
    var groupId = await getCurrentGroup();
    // determine the current user
    String uid = AuthService().getCurrentUID().toString();
    // get the old score data depending on the group
    var data = await groupCollection
        .doc(groupId)
        .get()
        .then((val) => val.get('points'));
    var getScore = data[uid];
    var oldPoints = getScore['score'];

    // calculate new points
    int newScore = oldPoints + points;

/*    return await groupCollection.doc(groupId).set({
      "points": {
        uid: {
          "score": newScore,
          "uid": uid,
        }
      }
    }, SetOptions(merge: true));*/
    // save new points depending on group and user ID
    return await groupCollection
        .doc(groupId)
        .get()
        .then((val) {
          val.reference.update({
            "points": {
              //['points.$uid']
              uid :{
                "score": newScore,
                "uid": uid,
              }
            }
          },);
    });
  }

  Future addVideo(String url) async {
    var groupId = getCurrentGroup();
    return await groupCollection
        .where('groupId', isEqualTo: groupId.toString())
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((documentSnapshot) {
        documentSnapshot.reference.update({
          'exercises': {'video': url}
        });
      });
    });
  }

  Future addGroupToUser(String groupId) async {
    final userID = AuthService().getCurrentUID();
    await FirebaseFirestore.instance.collection("users").doc(userID).update({
      "groups": FieldValue.arrayUnion([groupId]),
    });
  }

  Future addGroupMember(groupId) async {
    final userID = AuthService().getCurrentUID();
    await FirebaseFirestore.instance
        .collection("groups")
        .where('groupId', isEqualTo: groupId)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((documentSnapshot) {
        documentSnapshot.reference.update({
          "members": FieldValue.arrayUnion([userID]),
          "points": {
            //['points.$userID']
            userID: {"score": 0, "uid": userID}
          }
        });
      });
    });
  }

  Future<List<Map<String, dynamic>>> getGroups() async {
    List<String> groups = [];
    final userID = AuthService().getCurrentUID();
    final user =
        await FirebaseFirestore.instance.collection("users").doc(userID).get();

    print(user.get('groups'));

    final userGroups = await FirebaseFirestore.instance
        .collection("groups")
        .where('groupId', whereIn: user.get('groups'))
        .get();

    return userGroups.docs
        .map((e) => e.data()
          ..putIfAbsent('isActiveGroup', () => e.id == user.get('currentGroup'))
          ..putIfAbsent('groupDocumentId', () => e.id))
        .toList();
  }

  Stream<QuerySnapshot> get userData {
    return userCollection.snapshots();
  }

  Future createPoints(String groupID) async {
    String? uid = AuthService().getCurrentUID();
    String userName = await DatabaseService().getUserByID(uid!);
    String profilePic = await DatabaseService().getImageByID(uid);
    var group = await DatabaseService().getCurrentGroup();

    return await pointCollection.doc(groupID).set({
      'groupId': group,
      'user': userName,
      'image': profilePic,
      'points': 0
    });
  }

/*  Future changePoints(int points) async {
    var group = await DatabaseService().getCurrentGroup();
    var data = await pointCollection
        .doc(group)
        .get()
        .then((val) {
          val.docs.forEach((docSnapshot){
            docSnapshot.reference.update({

            })
          })
    }
    });

    .then((querySnapshot) {
    querySnapshot.docs.forEach((documentSnapshot) {
    documentSnapshot.reference.update({
    "members": FieldValue.arrayUnion([userID]),
    "points": {
    userID: {"score": 0, "uid": userID}
    }
    });
    });

  }*/

  // create group
  Future<String> createGroup(
      String userId, String groupName, String groupId, String groupIcon) async {
    DocumentReference groupDocRef = await groupCollection.add({
      'groupName': groupName,
      'groupIcon': groupIcon,
      'admin': userId,
      'members': [],
      'groupId': groupId,
      'points': {},
      'exercises': [],
    });
    return groupDocRef.id;

/*    await groupDocRef.update({
      'members': FieldValue.arrayUnion([uid! + '_' + userName]),
      'groupId': groupDocRef.id
    });

    DocumentReference userDocRef = userCollection.doc(uid);
    return await userDocRef.update({
      'groups': FieldValue.arrayUnion([groupDocRef.id + '_' + groupName])
    });*/
  }

  // join group
  Future joinGroup(String groupId, String userId) async {
    await groupCollection.doc(groupId).update({
      'members': FieldValue.arrayUnion([userId])
    });
    await userCollection.doc(userId).update({'groups': groupId});
  }

  static UploadTask? uploadFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putFile(file);
    } on FirebaseException catch (e) {
      return null;
    }
  }

  static UploadTask? uploadBytes(String destination, Uint8List data) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putData(data);
    } on FirebaseException catch (e) {
      return null;
    }
  }

  static Future<List<String>> _getDownloadLinks(List<Reference> refs) =>
      Future.wait(refs.map((ref) => ref.getDownloadURL()).toList());

  static Future<List<FirebaseFile>> listAll(String path) async {
    final ref = FirebaseStorage.instance.ref(path);
    final result = await ref.listAll();

    final urls = await _getDownloadLinks(result.items);

    return urls
        .asMap()
        .map((index, url) {
          final ref = result.items[index];
          final name = ref.name;
          final file = FirebaseFile(ref: ref, name: name, url: url);

          return MapEntry(index, file);
        })
        .values
        .toList();
  }

  static Future downloadFile(Reference ref) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${ref.name}');

    await ref.writeToFile(file);
  }
}

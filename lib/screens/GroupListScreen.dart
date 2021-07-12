
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:keep_on_moving/model/GroupModel.dart';
import 'package:keep_on_moving/screens/ToastMessage.dart';
import 'package:keep_on_moving/services/database.dart';

class GroupList extends StatefulWidget{

  @override
  _GroupList createState() => _GroupList();
}


class _GroupList extends State<GroupList>{

  String groupID = "";

  //var groups = DatabaseService().getGroups();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.home), onPressed: () { Navigator.pushReplacementNamed(context, 'HomeScreen'); },),
        actions: [
          TextButton(
            onPressed: () { groupDialog(context); },
            child: Text(' +  Gruppe beitreten'),
            style: TextButton.styleFrom(primary: Colors.white),
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseService().getGroups(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          print(data);
          return GridView(
              scrollDirection: Axis.vertical,           //default
              reverse: false,                           //default
              controller: ScrollController(),
              primary: false,
              shrinkWrap: true,
              padding: EdgeInsets.all(10.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 5.0,
                crossAxisSpacing: 5.0,
              ),
              addAutomaticKeepAlives: true,             //default
              addRepaintBoundaries: true,               //default
              addSemanticIndexes: true,                 //default
              semanticChildCount: 0,
              cacheExtent: 0.0,
              dragStartBehavior: DragStartBehavior.start,
              clipBehavior: Clip.hardEdge,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
              children: data.map((g) => showGroup(g)).toList(),
          );
        },
      )
    );
  }

  Widget showGroup(var group){
    return GestureDetector(
      onLongPress: (){

      },
      onTap: () async {
        await DatabaseService().updateCurrentGroup(group['groupDocumentId']);
        setState(() {
        });
      },
      child: buildGroup(group)
    );
  }

  Widget buildGroup(Map<String, dynamic> group) {
    return Container(
      color: group['isActiveGroup'] ? Colors.black54 : Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 30),
              ClipOval(
                child: Material(
                  color: Colors.transparent,
                  child: Image.network(
                    group['groupIcon'],
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                    //padding: EdgeInsets.all(24),
                  ),
                ),
              ),
              SizedBox(width: 20),
            ],
          ),
          SizedBox(height:5),
          Text(
            group['groupName'],
            textAlign: TextAlign.center,
          ),
          SizedBox(height:5),
          Text(
            group['groupId'],
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> groupDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Welcher Gruppe möchten Sie beitreten?'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Gruppen-ID:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold
                      )),
                  SizedBox(height: 30),
                  TextField(
                      keyboardType: TextInputType.name,
                      autocorrect: false,
                      onChanged: (value) {
                        groupID = value;
                      }
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
                  var result = await FirebaseFirestore.instance.collection('groups')
                      .where('groupId', isEqualTo: groupID).get();
                  final List < DocumentSnapshot > documents = result.docs;

                  if (documents.length > 0) {

                    DatabaseService().addGroupToUser(groupID);
                    DatabaseService().addGroupMember(groupID);
                    DatabaseService().updateCurrentGroup(documents.first.id);
                    ToastMessage.popUp("Gruppe wurde hinzugefügt!");
                    Navigator.of(context, rootNavigator: true).pop();
                    Navigator.pushNamed(context, 'GroupListScreen');

                  } else {
                    ToastMessage.popUp("Gruppe konnte nicht gefunden werden.");
                  }

                }, // Gruppe in Firebase suchen, User hinzufügen, in der Liste anzeigen
                child: const Text('Beitreten'),
              ),
            ],
          );
        });
  }

}
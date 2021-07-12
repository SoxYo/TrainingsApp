import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:keep_on_moving/screens/Authentification.dart';
import 'package:keep_on_moving/services/auth.dart';
import 'package:keep_on_moving/services/database.dart';

class Navigation extends StatelessWidget {

  String groupId;
  String groupName;
  String groupPic;

  Navigation({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.groupPic
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          buildGroup(groupId, context),
          ListTile(
            leading: Icon(Icons.emoji_events),
            title: Text('Ranking'),
            onTap: () =>
                {Navigator.pushReplacementNamed(context, 'RankingScreen')},
          ),
          ListTile(
            leading: Icon(Icons.group_add),
            title: Text('Neue Gruppe erstellen'),
            onTap: () => {Navigator.pushReplacementNamed(context, 'CreateGroupScreen')},
          ),
          ListTile(
            leading: Icon(Icons.sync_alt),
            title: Text('Gruppe wechseln'),
            onTap: () => {Navigator.pushReplacementNamed(context, 'GroupListScreen')},
          ),
          ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('Profil'),
            onTap: () => {Navigator.pushReplacementNamed(context, 'ProfileScreen')},
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () async {
              await AuthService().logOut();
              Navigator.pushReplacementNamed(context, 'Authenticate');
            },
          ),
        ],
      ),
    );
  }

  Widget buildGroup(String groupId, BuildContext context) {

    Image img = Image.network(groupPic);

    return new FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future:
          FirebaseFirestore.instance.collection('groups').doc(groupId).get(),
      builder: (_, snapshot) {
        if (snapshot.hasError) {

        }
        if (snapshot.hasData) {
          dynamic snap = DatabaseService().getCurrentGroup();

         /* Map<String, dynamic>? data = snapshot.data!.data();
          groupName = data!['groupName'];
          dynamic groupPic = data['groupIcon'];
          if (groupPic == "") img = Image.asset("assets/images/women_running.jpg");
          else img = Image.network(groupPic);*/
        }
        return SizedBox(
          child: DrawerHeader(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                groupName, // name of the group
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: img.image,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> rankingData() async {

    String currentGId = await DatabaseService().getCurrentGroup();
    Map<String, dynamic> rankingData = await DatabaseService().getPointList(currentGId);
    rankingData.forEach((key, value) {
      var id = DatabaseService().getUserByID(key.toString()).toString();
      var pic = DatabaseService().getImageByID(key.toString()).toString();
      rankingData.putIfAbsent("userName", () => id);
      rankingData.putIfAbsent("userProfile", () => pic);
      //rankingList.add(new RankingElement(imagePath: pic.toString(), userName: id.toString(), points: value['score']));
    });
    print("Ranking: ");
    print(rankingData);
    print("RankingEnde.");
    return rankingData;
  }
}

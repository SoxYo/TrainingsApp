import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keep_on_moving/model/RankingElement.dart';
import 'package:keep_on_moving/model/UserModel.dart';
import 'package:keep_on_moving/services/auth.dart';
import 'package:keep_on_moving/services/database.dart';
import 'package:keep_on_moving/widgets/LoadingWidget.dart';

class RankingScreen extends StatefulWidget {
  @override
  _RankingScreen createState() => _RankingScreen();
}

class _RankingScreen extends State<RankingScreen> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {

    var currentUserId = AuthService().getCurrentUID();
    List<String> userIds = [];
    List<RankingElement> ranking = [];

    return FutureBuilder<Map<String, dynamic>>(
        future: rankingData(),
        builder: (_, snapshot) {
          if (snapshot.hasError) {}
          if (!snapshot.hasData) {}

          var data = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text('Ranking'),
              leading: IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, 'HomeScreen');
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.update),
                  onPressed: () async {
                    userIds = getAllMembers();
                  },
                )
              ],
            ),
            body: Column(
              children: [
                Flexible(
                  flex: 1,
                  child: SizedBox(
                    height: 100,
                    child: Center(
                      child: Text(
                        'Bestenliste am ' + getDate(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    //height: 40,
                    //color: Colors.lightGreen[200],
                    // child: Text('Bestenliste mit Datum'),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: !data.containsKey(currentUserId) || data[currentUserId].isEmpty
                      ? Container(
                          child: Text('Daten konnten nicht geladen werden.'),
                        )
                      : ListView.builder(
                          itemCount: userIds.length,
                          itemBuilder: (BuildContext context, int index) {

                            for(var user in userIds){
                              print("In der Liste: $user");
                              ranking.add((data[user].map((v) => buildRankingElement(v[user]['userName'], v[user]['score'], v[user]['profilePic']))));
                            }
                            return Container(
                              child: buildRankingElement(ranking[index].userName, ranking[index].points.toString(), ranking[index].imagePath)
                            );
                          },
                  ),
                ),
              ],)
            );
        });
  }

  String getDate() {
    String day = DateTime.now().day.toString();
    String month = DateTime.now().month.toString();
    String year = DateTime.now().year.toString();
    return day + '.' + month + '.' + year;
  }

  Widget buildRankingElement(String name, String points, String imageUrl) {
    Image img;
    if (imageUrl == null || imageUrl == "")
      img = Image.asset('assets/images/profile_dummy.png');
    else
      img = Image.network(imageUrl);

    return Container(
      padding: EdgeInsets.all(5.0),
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Container(
        child: Row(
          children: [
            Flexible(
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(fit: BoxFit.fill, image: img.image),
                ),
              ),
            ),
            Flexible(child: SizedBox(width: 10)),
            Flexible(
              flex: 3,
              child: Container(
                width: 200,
                child: Text(name),
              ),
            ),
            Flexible(flex: 5, child: SizedBox(width: 200)),
            Flexible(
              flex: 1,
              child: Container(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    points,
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Future<Map<String, dynamic>>
  Future<Map<String, dynamic>> rankingData() async {
    Map<String, dynamic> user = await DatabaseService().getCurrentUser();
    String currentGId = await DatabaseService().getCurrentGroup();
    print(currentGId);
    Map<String, dynamic> rankingData =
        await DatabaseService().getPointList(currentGId);
/*    var id;
    var pic;
    rankingData.forEach((key, value) {
      rankingData.putIfAbsent("userName", () => user['name']);
      rankingData.putIfAbsent("profilePic", () => user['imagePath']);
    });*/
    rankingData.putIfAbsent("userName", () => user['name']);
    rankingData.putIfAbsent("profilePic", () => user['imagePath']);
    print("Ranking:$rankingData");
    return rankingData;
  }

  getAllMembers(){
    String currentGId = DatabaseService().getCurrentGroup() as String;
    return DatabaseService().getMembers(currentGId);
  }
}

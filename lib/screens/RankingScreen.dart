import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keep_on_moving/model/RankingElement.dart';
import 'package:keep_on_moving/model/UserModel.dart';
import 'package:keep_on_moving/services/database.dart';
import 'package:keep_on_moving/widgets/LoadingWidget.dart';

class RankingScreen extends StatefulWidget {
  @override
  _RankingScreen createState() => _RankingScreen();
}

class _RankingScreen extends State<RankingScreen> {
  List<RankingElement> rankingList = [];

  @override
  Widget build(BuildContext context) {
    print(rankingList.length);

    return FutureBuilder(
        future: rankingData(),
        builder: (_, snapshot) {
          if (snapshot.hasError) {}
          if (!snapshot.hasData) {}

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
                    rankingData();
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
                  child: ListView.builder(
                      itemCount: rankingList.length,
                      itemBuilder: (BuildContext context, int index) {
                        rankingList
                            .sort((a, b) => a.points.compareTo(b.points));
                        return buildRankingElement(
                            rankingList[index].userName.toString(),
                            rankingList[index].points.toString());
                      }),
                ),
              ],
            ),
          );
        });
  }

  String getDate() {
    String day = DateTime.now().day.toString();
    String month = DateTime.now().month.toString();
    String year = DateTime.now().year.toString();
    return day + '.' + month + '.' + year;
  }

  Widget buildRankingElement(String name, String points) {
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
                    image: DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage('assets/images/profile_dummy.png'))),
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
    int count = 0;
    String currentGId = await DatabaseService().getCurrentGroup();
    Map<String, dynamic> rankingData =
        await DatabaseService().getPointList(currentGId);
    rankingData.forEach((key, value) async {
      var id = await DatabaseService().getUserByID(value['uid']);
      var pic = await DatabaseService().getImageByID(value['uid']);
      rankingList.add(new RankingElement(
          imagePath: pic.toString(), userName: id, points: value['score']));
          print(count);
          count++;
    });
    print(count);
    return rankingData;
  }
}

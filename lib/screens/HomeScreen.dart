import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:keep_on_moving/model/ExerciseModel.dart';
import 'package:keep_on_moving/screens/LoginScreen.dart';
import 'package:keep_on_moving/services/auth.dart';
import 'package:keep_on_moving/user_preferences/UserPreferences.dart';
import 'package:keep_on_moving/widgets/AddExerciseWidget.dart';
import 'package:keep_on_moving/widgets/LoadingWidget.dart';
import 'package:keep_on_moving/widgets/ProfileWidget.dart';
import 'package:keep_on_moving/widgets/NavigationWidget.dart';
import 'package:keep_on_moving/services/database.dart';
import 'package:keep_on_moving/widgets/Video.dart';
import 'package:keep_on_moving/widgets/VideoWidget.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  var _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {

    String? uId = AuthService().getCurrentUID();
    final gId = "0";
    // Map<String, dynamic> group = {};

/*    final gId = ModalRoute
        .of(context)!
        .settings
        .arguments as String;*/


    // var groupFuture =
    //     FirebaseFirestore.instance.collection('groups').doc(gId).get();

    // final user = AuthService().getCurrentUser();
    var tabBar = TabBar(
      controller: _tabController,
      isScrollable: false,
      indicatorColor: Colors.black,
      labelColor: Colors.black,
      tabs: [
        Tab(icon: Icon(Icons.run_circle_outlined)),
        Tab(icon: Icon(Icons.fitness_center_rounded)),
        Tab(icon: Icon(Icons.self_improvement_rounded)),
        Tab(icon: Icon(Icons.star_border_outlined)),
      ],
    );

    return FutureBuilder<Map<String, dynamic>>(
        future: activeGroup(),
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            // show snackbar
          }
          if (!snapshot.hasData) {

            return Center(child: Loading(),);
          }

          var data = snapshot.data!;
          return Scaffold(
            drawer: Navigation(groupId: data['groupId'], groupName: data['groupName'], groupPic: data['groupIcon']),
            body: NestedScrollView(
              headerSliverBuilder: (context, isScrolled) => [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background:
                        ProfileWidget(username: data["username"], profileImage: data['profileImage'], group: data
                            ),
                  ),
                  bottom: PreferredSize(
                    child: Container(
                      // center the tabs
                      alignment: Alignment.center,
                      width: double.infinity,
                      color: Colors.white,
                      child: tabBar,
                    ),
                    preferredSize:
                        Size(double.infinity, tabBar.preferredSize.height),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  // first tab bar for endurance training
                  Container(
                    child: Center(
                      child: !data.containsKey("exercises") || data["exercises"].isEmpty
                          ? Column(
                        children: [
                          Flexible(child: SizedBox(height: 50)),
                          Flexible(
                            child: Text(
                                'Es sind noch keine Ausdauerübungen verfügbar.'),
                          ),
                          if (data["admin"] == uId)
                            Flexible(child: AddExercise(category: 'Ausdauer')),
                        ],)
                          : ListView(
                          children: data['exercises']
                              .where((v) => v['category'] == 'Ausdauer')
                              .map((v) => Video(videoUrl: v['video'], title: v['title'], thumbnailUrl: v['thumbnail'],)).toList().cast<Widget>()
                          //.map((v) => Text(v['title'])/*Video(exercise: v)*/).toList().cast<Widget>()
                            ..addAll([
                              if (data["admin"] == uId)
                                AddExercise(category: 'Ausdauer'),
                              // if user is admin
                            ])),
                    ),
                  ),
                  // second tab bar for weight training
                  Container(
                    child: Center(
                      child: !data.containsKey("exercises") || data["exercises"].isEmpty
                          ? Column(
                        children: [
                          Flexible(child: SizedBox(height: 50)),
                          Flexible(
                            child: Text(
                                'Es sind noch keine Kraftübungen verfügbar.'),
                          ),
                          if (data["admin"] == uId)
                            Flexible(child: AddExercise(category: 'Kraft')),
                        ],)
                          : ListView(
                          children: data['exercises']
                              .where((v) => v['category'] == 'Kraft')
                              .map((v) => Video(videoUrl: v['video'], title: v['title'], thumbnailUrl: v['thumbnail'],)).toList().cast<Widget>()
                          //.map((v) => Text(v['title'])/*Video(exercise: v)*/).toList().cast<Widget>()
                            ..addAll([
                              if (data["admin"] == uId)
                                AddExercise(category: 'Kraft'),
                              // if user is admin
                            ])),
                    ),
                  ),
                  // third tab bar for flexibility training
                  Container(
                    child: Center(
                      child: !data.containsKey("exercises") || data["exercises"].isEmpty
                          ? Column(
                        children: [
                          Flexible(child: SizedBox(height: 50)),
                          Flexible(
                            child: Text(
                                'Es sind noch keine Beweglichkeitsübungen verfügbar.'),
                          ),
                          if (data["admin"] == uId)
                            Flexible(child: AddExercise(category: 'Beweglichkeit')),
                        ],)
                          : ListView(
                          children: data['exercises']
                              .where((v) => v['category'] == 'Beweglichkeit')
                              .map((v) => Video(videoUrl: v['video'], title: v['title'], thumbnailUrl: v['thumbnail'],)).toList().cast<Widget>()
                          //.map((v) => Text(v['title'])/*Video(exercise: v)*/).toList().cast<Widget>()
                            ..addAll([
                              if (data["admin"] == uId)
                                AddExercise(category: 'Beweglichkeit'),
                              // if user is admin
                            ])),
                    ),
                  ),
                  // fourth tab bar for random stuff
                  Container(
                    child: Center(
                      child: !data.containsKey("exercises") || data["exercises"].isEmpty
                          ? Column(
                            children: [
                                Flexible(child: SizedBox(height: 50)),
                                Flexible(
                                  child: Text(
                                    'Es sind noch keine Bonusübungen verfügbar.'),
                                ),
                                if (data["admin"] == uId)
                                Flexible(child: AddExercise(category: 'Bonus')),
                            ],)
                          : ListView(
                          children: data['exercises']
                              .where((v) => v['category'] == 'Bonus')
                              .map((v) => Video(videoUrl: v['video'], title: v['title'], thumbnailUrl: v['thumbnail'],)).toList().cast<Widget>()
                          //.map((v) => Text(v['title'])/*Video(exercise: v)*/).toList().cast<Widget>()
                            ..addAll([
                              if (data["admin"] == uId)
                                AddExercise(category: 'Bonus'),
                              // if user is admin
                            ])),
                    ),
                  ),
                ],
              ),
            ),
          );}



          );

  }

  Future<Map<String, dynamic>> activeGroup() async{
    Map<String,dynamic> user = await DatabaseService().getCurrentUser();
    String currentGId = await DatabaseService().getCurrentGroup();
    Map<String, dynamic> groupData = await DatabaseService().getGroup(currentGId) ?? {};
    groupData.putIfAbsent("currentUserId", () => user['id']);
    groupData.putIfAbsent("username", () => user['name']);
    groupData.putIfAbsent("profileImage", () => user['imagePath']);
    return groupData;
  }
}

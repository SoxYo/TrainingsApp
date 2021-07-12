import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keep_on_moving/screens/Authentification.dart';
import 'package:keep_on_moving/screens/CreateGroupScreen.dart';
import 'package:keep_on_moving/screens/GroupListScreen.dart';
import 'package:keep_on_moving/screens/HomeScreen.dart';
import 'package:keep_on_moving/screens/ProfileScreen.dart';
import 'package:keep_on_moving/screens/RankingScreen.dart';
import 'package:keep_on_moving/screens/RegistrationScreen.dart';
import 'package:keep_on_moving/screens/ResultScreen.dart';
import 'package:keep_on_moving/screens/Root.dart';
import 'package:keep_on_moving/screens/VideoWatchScreen.dart';
import 'package:keep_on_moving/services/auth.dart';
import 'package:keep_on_moving/widgets/VideoPlayerWidget.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'model/UserModel.dart';
import 'screens/LoginScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(KeepOnMoving());
  });
}

class KeepOnMoving extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel?>.value(
        value: AuthService().user,
        initialData: null,
        child: MaterialApp(
           title: 'Keep on Moving',
           theme: ThemeData(
           primaryColor: Colors.pink[900],
           scaffoldBackgroundColor: Colors.white,
           accentColor: Colors.pink[700]),
           home: Root(),
           routes: {
              'HomeScreen': (context) => HomeScreen(),
              'Authenticate': (context) => Authenticate(),
              'RegistrationScreen': (context) => RegistrationScreen(),
              'LoginScreen': (context) => LoginScreen(),
              'RankingScreen': (context) => RankingScreen(),
              'ProfileScreen': (context) => Profile(),
              'GroupListScreen': (context) => GroupList(),
              'CreateGroupScreen': (context) => CreateGroup(),
              //'ResultScreen': (context) => ResultScreen(),
              //'VideoWatchScreen': (context) => VideoWatchScreen(exercise: ),
           },
        ),
    );
  }
}

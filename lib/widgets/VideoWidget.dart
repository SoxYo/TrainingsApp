import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keep_on_moving/model/ExerciseModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_on_moving/screens/HomeScreen.dart';
import 'package:keep_on_moving/screens/ResultScreen.dart';
import 'package:keep_on_moving/services/database.dart';
import 'package:keep_on_moving/widgets/VideoPlayerWidget.dart';
import 'package:video_player/video_player.dart';


class VideoWidget extends StatefulWidget {

  final String videoUrl;

  const VideoWidget({
    Key? key,
    required this.videoUrl,
  }) : super(key: key);

  @override
  _VideoWidget createState() => _VideoWidget();
}

class _VideoWidget extends State<VideoWidget>{

  //final asset = 'assets/videos/demo.mp4';
  late VideoPlayerController controller;
  bool finished = true;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.network(widget.videoUrl)
      ..addListener(() => setState((){
        // check if the video is at its end
        if (!controller.value.isPlaying && controller.value.isInitialized &&
            (controller.value.duration == controller.value.position) && finished)
        {
          setState(() {
            // pop up the confirmation window
            confirmExercise(context);
          });
        }}))
      ..setLooping(false) // do not repeat the video
      ..initialize().then((_) => controller.play());  // start video
    setLandscape();
  }

  @override
  void dispose(){
    controller.dispose();
    setAllOrientations();
    super.dispose();
  }

  Future setLandscape() async {
    // hide overlays statusbar
    await SystemChrome.setEnabledSystemUIOverlays([]);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future setAllOrientations() async {
    await SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }


  @override
  Widget build(BuildContext context){
    final isMuted = controller.value.volume == 0;

    return Column(
      children: [
        MyVideoPlayer(controller: controller),
      ],
    );
  }

  Future<void> confirmExercise(BuildContext context) {
    finished = false;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Punktvergabe'),
            content: Text('Haben Sie die Übung erfolgreich und vollständig absolviert?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  DatabaseService().addPoints(getPoints());
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ResultScreen(points: pointsToString())));
                  // Punkte beim User anrechnen mit getPoints
                },
                child: const Text('Ja'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ResultScreen(points: '0')));
                },
                child: const Text('Nein'),
              ),
            ],
          );
        });
  }

  String pointsToString(){
    // get the number of whole minutes of this video
    int minutes = controller.value.duration.inMinutes;
    // multiply with 10 to get the amount of points
    int points = minutes*10;
    return points.toString();
  }

  int getPoints(){
    // get the number of whole minutes of this video
    int minutes = controller.value.duration.inMinutes;
    // multiply with 10 to get the amount of points
    int points = minutes*10;
    return points;
  }
}


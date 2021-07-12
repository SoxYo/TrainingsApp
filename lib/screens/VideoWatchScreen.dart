import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keep_on_moving/model/ExerciseModel.dart';
import 'package:keep_on_moving/widgets/VideoWidget.dart';

class VideoWatchScreen extends StatefulWidget{

  final String videoUrl;
  static const route = 'VideoWatchScreen';

  VideoWatchScreen({required this.videoUrl});

  @override
  _VideoWatchScreen createState() =>  _VideoWatchScreen();

}

class _VideoWatchScreen extends State<VideoWatchScreen>{

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);
  }

  @override
  dispose(){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VideoWidget(videoUrl: widget.videoUrl),
    );
  }
}
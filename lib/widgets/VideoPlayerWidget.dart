import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keep_on_moving/widgets/LoadingWidget.dart';
import 'package:video_player/video_player.dart';

import 'ShowVideo.dart';

class MyVideoPlayer extends StatelessWidget {
  final VideoPlayerController controller;

  const MyVideoPlayer({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // get the size of the screen
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return controller.value.isInitialized
        ? Container(
            alignment: Alignment.topCenter,
            width: screenWidth,
            height: screenHeight,
            child: buildVideo())
        : Container(
            child: Center(child: Loading()),
          );
  }

  Widget buildVideo() => Stack(
        children: <Widget>[
          buildVideoPlayer(),
          Positioned.fill(child: ShowVideo(controller: controller)),
        ],
      );

  Widget buildVideoPlayer() => AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: VideoPlayer(controller));
}

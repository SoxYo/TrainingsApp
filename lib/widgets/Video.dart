import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keep_on_moving/model/ExerciseModel.dart';
import 'package:keep_on_moving/screens/VideoWatchScreen.dart';

import 'VideoWidget.dart';

class Video extends StatelessWidget{

  final String videoUrl;
  final String thumbnailUrl;
  final String title;

  const Video({
    Key? key,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.title,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VideoWatchScreen(videoUrl: videoUrl))),
      child: Column(
          children: [
            Stack(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(),
                    child: Container(
                      height: 220,
                      width: 330,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(thumbnailUrl),
                          )
                      ),
                    ),
                  ),
                ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 3.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.0,
                                ),
                              )),
                        ],
                      ),
                    )
                  ]
              ),
            )
          ]
      ),
    );
  }

}
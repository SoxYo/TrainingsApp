import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResultScreen extends StatefulWidget{

  final String points;

  ResultScreen({required this.points});

  @override
  _ResultScreen createState() => _ResultScreen();

}

class _ResultScreen extends State<ResultScreen>{

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[100],
      body: Center(
        child: Container(
          child: Column(
            children: [
              Flexible(child: SizedBox(height: 200)),
              Flexible(
                child: Text(
                  'Vielen Dank!',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink[600],
                  ),
                ),
              ),
              Flexible(child: SizedBox(height:25)),
              Flexible(
                child: Text(
                  'Erzielte Punkte: '+widget.points,
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.pink
                  ),
                ),
              ),
              Flexible(child: SizedBox(height: 50)),
              Flexible(
                child: TextButton(onPressed: (){
                  Navigator.pushNamed(context, 'RankingScreen');
                  },
                    child: Text(
                        'Zum Ranking',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.pink
                      ),
                    ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white),


                  ),
                ),
              )
            ],
          )
        )
      )
    );
  }
}
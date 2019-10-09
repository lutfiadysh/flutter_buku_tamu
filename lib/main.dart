import 'dart:async';
import 'page/startpage.dart';

import'package:flutter/material.dart';

void main() => runApp(new MaterialApp(
  theme:
      ThemeData(primaryColor:Colors.blue,accentColor: Colors.blueAccent),
  debugShowCheckedModeBanner: false,
  home: SplashScreen(),
));

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() =>  _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>{

  @override
  void initState(){
    super.initState();

    loadData();
  }

  Future<Timer> loadData() async {
    return new Timer(Duration(seconds: 2), onDoneLoading);
  }

  onDoneLoading() async {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => StartPage()));
  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                          backgroundColor: Colors.white,
                        radius: 50.0,
                        child: Image.asset(
                          "assets/logo.png",
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                      ),
                      Text(
                        "Buku Tamu",style: TextStyle(
                          fontFamily: "Poppins-Bold",
                          fontSize: 24,
                          letterSpacing: .6,
                          fontWeight: FontWeight.bold
                      ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new CircularProgressIndicator(
                      backgroundColor: Colors.greenAccent,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                    Text(" Lutfi Ardiansyah  \n \n    GEN 15 RPL ",style: TextStyle(
                        fontFamily: "Poppins-bold",
                        fontSize: 16.0,),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
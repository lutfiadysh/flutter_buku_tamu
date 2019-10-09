import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'dart:math';
import 'package:path/path.dart' as path;
import 'startpage.dart';
import 'package:intl/intl.dart';

final databaseReference = Firestore.instance;
const chars = "abcdefghijklmnopqrstuvwxyz0123456789";
final GlobalKey <ScaffoldState> _scaffoldState = new GlobalKey<ScaffoldState>();

String RandomString(int strlen) {
  Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
  String result = "";
  for (var i = 0; i < strlen; i++) {
    result += chars[rnd.nextInt(chars.length)];
  }
  return result;
}

void main() => runApp(MaterialApp(
  home: HomePage(),
  debugShowCheckedModeBanner: false,
));

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Offset>_points = <Offset>[];
  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;
  String resultText = "";

  File _image;
  File _ktp;

  Future getImage(bool isCamera) async{
    File image;
    if(isCamera){
      image = await ImagePicker.pickImage(source: ImageSource.camera);
    }else{
      image = await ImagePicker.pickImage(source: ImageSource.gallery);
    }
    setState(() {
      _image = image;
    });
  }

  Future getKTP(bool isCamera) async{
    File ktp;
    if(isCamera){
      ktp = await ImagePicker.pickImage(source: ImageSource.camera);
    }else{
      ktp = await ImagePicker.pickImage(source: ImageSource.gallery);
    }
    setState(() {
      _ktp = ktp;
    });
  }


  Widget horizontalLine() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.0),
    child: Container(
      width: ScreenUtil.getInstance().setWidth(140),
      height: 1.0,
      color: Colors.black26.withOpacity(.2),
    ),
  );

  Widget signatureShow(BuildContext context){
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child:GestureDetector(
          onPanUpdate: (DragUpdateDetails details){
            setState(() {
              RenderBox object = context.findRenderObject();
              Offset _localPosition =
              object.globalToLocal(details.globalPosition);
              _points = new List.from(_points)..add(_localPosition);
            });
          },
          onPanEnd: (DragEndDetails details)=> _points.add(null),
          child: new CustomPaint(
            painter: new Signature(points: _points),
            size: Size(200, 100),),
        ),
      );
  }

  TextEditingController taskNameInputController;
  TextEditingController taskFromInputController;
  TextEditingController taskToInputController;

  var now = new DateTime.now().toString();

  @override
  void initState() {
    taskNameInputController = new TextEditingController();
    taskFromInputController = new TextEditingController();
    taskToInputController = new TextEditingController();

    super.initState();
    initSpeechRecognizer();
  }

  void initSpeechRecognizer(){
    _speechRecognition = SpeechRecognition();

    _speechRecognition.setAvailabilityHandler(
        (bool result) => setState(() => _isAvailable = result),
    );
    _speechRecognition.setRecognitionStartedHandler(
        () => setState(() => _isListening = true),
    );
    _speechRecognition.setRecognitionResultHandler(
        (String speech) => setState(() => taskNameInputController.text = speech),
    );
    _speechRecognition.setRecognitionCompleteHandler(
        () => setState(() => _isListening = false),
    );
    _speechRecognition.activate().then(
        (result) => setState(() => _isAvailable = result),
    );
    _speechRecognition.setCurrentLocaleHandler((String locale) =>
        setState(() => locale = locale));
  }


  void addData() async {
    var r = (RandomString(20));
    var rand = (RandomString(20));
    final StorageReference firebaseStorageRef =
    FirebaseStorage.instance.ref().child(r.toString());
    final StorageUploadTask task =
    firebaseStorageRef.putFile(_image);
    final StorageReference firebaseStorage =
    FirebaseStorage.instance.ref().child(rand.toString());
    final StorageUploadTask tsk =
    firebaseStorage.putFile(_ktp);
    await databaseReference.collection("tamu")
        .add({
      'tanggal':now,
      'foto':r,
      'nama': taskNameInputController.text,
      'alamat': taskFromInputController.text,
      'tujuan': taskToInputController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    ScreenUtil.instance =
        ScreenUtil(width: 750, height: 1400, allowFontScaling: true);
    return new Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: Image.asset("assets/image_01.png"),
              ),
              Expanded(
                child: Container(),
              ),
              Image.asset("assets/image_02.png")
            ],
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(left: 28.0, right: 28.0, top: 60.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Image.asset(
                        "assets/logo.png",
                        width: ScreenUtil.getInstance().setWidth(110),
                        height: ScreenUtil.getInstance().setHeight(110),
                      ),
                      Text("BUKU TAMU",
                          style: TextStyle(
                              fontFamily: "Poppins-Bold",
                              fontSize: ScreenUtil.getInstance().setSp(46),
                              letterSpacing: .6,
                              fontWeight: FontWeight.bold)),
                      SizedBox(
                        width: ScreenUtil.getInstance().setWidth(150),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_back,size: 50,),
                        onPressed: () { Navigator.pushReplacement(
                            context,
                            new MaterialPageRoute(
                                builder: (BuildContext context) => StartPage()));
                        },
                      )
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.getInstance().setHeight(180),
                  ),
                  new Container(
                  width: double.infinity,
                  height: ScreenUtil.getInstance().setHeight(1000),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            offset: Offset(0.0, 15.0),
                            blurRadius: 15.0),
                        BoxShadow(
                            color: Colors.black12,
                            offset: Offset(0.0, -10.0),
                            blurRadius: 10.0),
                      ]),
                  child: Padding(
                    padding: EdgeInsets.only(left: 40.0, right: 40.0, top: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Isi Data",
                            style: TextStyle(
                                fontSize: ScreenUtil.getInstance().setSp(45),
                                fontFamily: "Poppins-Bold",
                                fontWeight: FontWeight.bold,
                                letterSpacing: .6)),
                        SizedBox(
                          height: ScreenUtil.getInstance().setHeight(30),
                        ),
                        Text("Nama",
                            style: TextStyle(
                                fontFamily: "Poppins-Medium",
                                fontSize: ScreenUtil.getInstance().setSp(15))),
                        TextField(
                          decoration: InputDecoration(
                              hintText: "nama",
                              suffix:IconButton(
                                icon: Icon(Icons.mic),
                                onPressed: (){
                                  if(_isAvailable && !_isListening)
                                    _speechRecognition.listen(locale:'en-EN').then((result)=> print('result : $result'));
                                },
                              ),
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0)),
                          controller: taskNameInputController,
                        ),
                        SizedBox(
                          height: ScreenUtil.getInstance().setHeight(30),
                        ),
                        Text("Alamat",
                            style: TextStyle(
                                fontFamily: "Poppins-Medium",
                                fontSize: ScreenUtil.getInstance().setSp(15))),
                        TextField(
                          decoration: InputDecoration(
                              hintText: "Alamat",
                              suffix:IconButton(icon:Icon(Icons.mic),
                                  onPressed: (){
                                    if(_isAvailable && !_isListening)
                                      _speechRecognition
                                          .listen(locale: "en")
                                          .then((result) => print('$result'));
                                  }),
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0)),
                          controller: taskFromInputController,
                        ),
                        SizedBox(
                          height: ScreenUtil.getInstance().setHeight(35),
                        ),
                        Text("Tujuan",
                            style: TextStyle(
                                fontFamily: "Poppins-Medium",
                                fontSize: ScreenUtil.getInstance().setSp(15))),
                        TextField(
                          decoration: InputDecoration(
                              hintText: "Tujuan",
                              suffix:IconButton(icon:Icon(Icons.mic),
                                onPressed:(){
                                  if(_isAvailable && !_isListening)
                                    _speechRecognition
                                        .listen(locale: "en-EN")
                                        .then((resultTo) => print('$resultTo'));
                                },),
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0)),
                          controller: taskToInputController,
                        ),
                        SizedBox(
                          height: ScreenUtil.getInstance().setHeight(35),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.mode_edit),
                                  onPressed: (){
                                    showDialog(context: context,
                                      builder: (BuildContext context) => signatureShow(context),
                                    );
                                  },
                                ),
                                SizedBox(height: 10.0,),
                                IconButton(
                                  icon: Icon(Icons.camera_alt),
                                  onPressed: (){
                                    getImage(true);
                                  },
                                ),
                                _image == null? Text("Ambil foto ") : Image.file(_image, height: 50.0,width: 50.0,),
                                SizedBox(height: 10.0,),
                                IconButton(
                                  icon: Icon(Icons.camera_alt),
                                  onPressed: (){
                                    getKTP(true);
                                  },
                                ),
                                _ktp == null? Text("Foto ktp ") : Image.file(_ktp, height: 50.0,width: 50.0,),
                              ],
                            ),
                            SizedBox(
                              height: ScreenUtil.getInstance().setHeight(35),
                            ),

                            InkWell(
                              child: Container(
                                width: ScreenUtil.getInstance().setWidth(200),
                                height: ScreenUtil.getInstance().setHeight(100),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      Color(0xFF17ead9),
                                      Color(0xFF6078ea)
                                    ]),
                                    borderRadius: BorderRadius.circular(6.0),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Color(0xFF6078ea).withOpacity(.3),
                                          offset: Offset(0.0, 8.0),
                                          blurRadius: 8.0)
                                    ]),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () { addData();
                                    Navigator.pushReplacement(
                                        context,
                                        new MaterialPageRoute(
                                            builder: (BuildContext context) => SplashScreen()));
                                    },
                                    child: Center(
                                      child: Text("SIMPAN",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: "Poppins-Bold",
                                              fontSize: 18,
                                              letterSpacing: 1.0)),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                        )
                      ],
                    ),
                  ),
                  ),
                  SizedBox(height: ScreenUtil.getInstance().setHeight(40)),

                  SizedBox(
                    height: ScreenUtil.getInstance().setHeight(40),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      horizontalLine(),
                      Text("Lutfi Ardiasyah",
                          style: TextStyle(
                              fontSize: 16.0, fontFamily: "Poppins-Medium")),
                      horizontalLine()
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.getInstance().setHeight(40),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Signature extends CustomPainter{
  List<Offset>points;

  Signature({this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
    ..color = Colors.black
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 5.0;
    for(int i = 0; i < points.length - 1 ; i++){
      if(points[i] != null && points[i+1] != null){
        canvas.drawLine(points[i], points[i+1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(Signature oldDelegate) => oldDelegate.points != points;
}




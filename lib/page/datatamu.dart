import 'dart:core';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'startpage.dart';

void main() => runApp(MaterialApp(
  home: DataTamu(),
  debugShowCheckedModeBanner: false,
));

class DataTamu extends StatefulWidget {
  @override
  _DataTamuState createState() => new _DataTamuState();
}

class _DataTamuState extends State<DataTamu> {
  QuerySnapshot querySnapshot;
  @override
  void initState(){
    super.initState();
    getData().then((results){
      setState(() {
        querySnapshot = results;
      });
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
                    child: Scaffold(
                      body: _showDrivers(),
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
                      Text("Lutfi Ardiansyah",
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
  Widget _showDrivers() {
    if (querySnapshot != null) {
      return ListView.builder(
        primary: false,
        itemCount: querySnapshot.documents.length,
        padding: EdgeInsets.all(30),
        itemBuilder: (context, i)
        {
          return Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        height: 260.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage("${FirebaseStorage.instance.ref().child("gs://buku-tamu-f6cf7.appspot.com/${querySnapshot.documents[i].data['foto']}")}"),
                          ),
                        ),
                      ),
                  ),
                ExpansionTile(
                  trailing: Icon(
                    Icons.account_box
                  ),
                  title: Text("${querySnapshot.documents[i].data['nama']}"),
                  children: <Widget>[
                    Text("Tanggal  :  ${querySnapshot.documents[i].data['tanggal']}",style: TextStyle(fontWeight: FontWeight.bold),),
                    Text("Alamat   :  ${querySnapshot.documents[i].data['alamat']}",style: TextStyle(fontSize: 20),),
                    Text("Tujuan   :  ${querySnapshot.documents[i].data['tujuan']}",style: TextStyle(fontSize: 20),),
                  ],
                ),
              ],
            ),
          );
        },
      );
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  getData() async {
   return await Firestore.instance.collection('tamu').getDocuments();
  }
}
class Entry {
  Entry(this.title, [this.children = const <Entry>[]]);

  final String title;
  final List<Entry> children;
}
class EntryItem extends StatelessWidget {
  const EntryItem(this.entry);

  final Entry entry;

  Widget _buildTiles(Entry root) {
    if (root.children.isEmpty) return ListTile(title: Text(root.title));
    return ExpansionTile(
      key: PageStorageKey<Entry>(root),
      title: Text(root.title),
      children: root.children.map(_buildTiles).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }
}

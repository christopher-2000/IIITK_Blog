import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iiitk_app/components/posts.dart';
import 'package:iiitk_app/components/rounded_button.dart';
import 'package:iiitk_app/newpost.dart';
import 'package:iiitk_app/login_page.dart';
import 'components/posts.dart';
import 'components/loading.dart';
import 'package:photo_view/photo_view.dart';
import 'package:zoom_widget/zoom_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Post> postsList = [];
  final us = FirebaseAuth.instance.currentUser;
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  @override
  void initState() {
    super.initState();

    try {
      postsList.clear();
      DatabaseReference postRef =
          FirebaseDatabase.instance.reference().child("Posts");

      postRef.once().then((DataSnapshot snap) {
        var datas = snap.value;
        List keys = datas.keys.toList()..sort();

        //print(keys);
        List keyL = keys.reversed.toList();
        //print(keyL);

        for (var i in keyL) {
          Post posts = new Post(datas[i]['image'], datas[i]['description'],
              datas[i]['time'], datas[i]['date']);

          postsList.add(posts);
        }

        setState(() {});
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    postsList.reversed.toList();
    if (us.toString() != null.toString()) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          title: Text(
            "IIITK BLOG",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
          ),
        ),
        body: Container(
          child: postsList.length == 0
              ? Center(child: Text("No Posts!!Add a new One :)"))
              : ListView.builder(
                  itemCount: postsList.length,
                  itemBuilder: (context, index) {
                    return postsUI(
                        postsList[index].image,
                        postsList[index].description,
                        postsList[index].date,
                        postsList[index].time);
                  },
                ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(width: 1, color: Colors.green)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FlatButton(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.home_rounded,
                            size: 32,
                            color: Colors.blue,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0, bottom: 5),
                            child: Text(
                              "Home",
                              style: TextStyle(color: Colors.blue),
                            ),
                          )
                        ]),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      );
                    },
                  ),
                  FlatButton(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.add_a_photo_rounded,
                            size: 32,
                            color: Colors.black,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0, bottom: 5),
                            child: Text(
                              "Post",
                              style: TextStyle(color: Colors.black),
                            ),
                          )
                        ]),
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => UploadNewPost(),
                        ),
                      );
                    },
                  ),
                  FlatButton(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.settings,
                            size: 32,
                            color: Colors.black,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0, bottom: 5),
                            child: Text(
                              "Settings",
                              style: TextStyle(color: Colors.black),
                            ),
                          )
                        ]),
                    onPressed: () async {},
                  ),
                  FlatButton(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.logout,
                            size: 32,
                            color: Colors.black,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0, bottom: 5),
                            child: Text(
                              "Logout",
                              style: TextStyle(color: Colors.black),
                            ),
                          )
                        ]),
                    onPressed: _showMyDialog,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 250),
            child: Column(
              children: [
                Text(
                    "Sorry!!You Dont Have the Permission to Access this Page..Try signing in Again "),
                RoundedButton(
                  text: "Try Again",
                  color: Colors.green,
                  press: () {
                    Navigator.push(context,
                        CupertinoPageRoute(builder: (context) => LoginHere()));
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Out from IIITK Blog?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You will be logged out from this app.'),
              ],
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  TextButton(
                    child: Text('Logout'),
                    onPressed: () async {
                      Dialogs.showLoadingDialog(context, _keyLoader);
                      await FirebaseAuth.instance.signOut();
                      print(us);
                      Future.delayed(Duration(seconds: 3), () {
                        Navigator.of(_keyLoader.currentContext,
                                rootNavigator: true)
                            .pop();
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => LoginHere()));
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget postsUI(String image, String description, String date, String time) {
    Size size = MediaQuery.of(context).size;
    return Container(
        width: size.width * 0.8,
        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black, blurRadius: 5.0),
            ],
            border: Border.all(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          date,
                          style: Theme.of(context).textTheme.subtitle1,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          time,
                          style: Theme.of(context).textTheme.subtitle1,
                          textAlign: TextAlign.center,
                        ),
                      ]),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) =>
                                PhotoView(imageProvider: NetworkImage(image))));
                  },
                  child: Container(
                    decoration: BoxDecoration(color: Colors.grey),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: Image.network(
                        image,
                        fit: BoxFit.fill,
                        height: size.width * 0.6,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(description,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
          ],
        ));
  }
}

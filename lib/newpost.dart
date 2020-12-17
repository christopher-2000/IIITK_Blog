import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:iiitk_app/components/rounded_button.dart';
import 'package:iiitk_app/home_page.dart';
import 'package:iiitk_app/login_page.dart';
import 'package:iiitk_app/upload_photo.dart';
import 'components/loading.dart';
import 'components/rounded_button.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadNewPost extends StatefulWidget {
  @override
  _UploadNewPostState createState() => _UploadNewPostState();
}

class _UploadNewPostState extends State<UploadNewPost> {
  final us = FirebaseAuth.instance.currentUser;
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  File sampleImage;
  String _myValue;
  String url;
  final formKey = GlobalKey<FormState>();

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 60);
    setState(() {
      sampleImage = tempImage;
    });
  }

  Future captureImage() async {
    var tempImage = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 60);
    setState(() {
      sampleImage = tempImage;
    });
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void uploadImage() async {
    if (validateAndSave()) {
      Dialogs.showLoadingDialog(context, _keyLoader);
      final Reference postImageRef =
          FirebaseStorage.instance.ref().child("Post Images");

      var timeKey = DateTime.now();
      final UploadTask uploadTask =
          postImageRef.child(timeKey.toString() + ".jpg").putFile(sampleImage);

      var imageUrl = await (await uploadTask.whenComplete(() => null))
          .ref
          .getDownloadURL();
      print("Image Url " + imageUrl);
      saveToDatabase(imageUrl);
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      goToHome();
    }
  }

  void saveToDatabase(url) {
    var dbTimeKey = DateTime.now();
    var formatDate = DateFormat('MMM d, yyyy');
    var formatTime = DateFormat('EEEE, hh:mm aaa');

    String date = formatDate.format(dbTimeKey);
    String time = formatTime.format(dbTimeKey);

    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
    var data = {
      "image": url,
      "description": _myValue,
      "date": date,
      "time": time,
      "user": us.email,
    };
    String id = dbTimeKey.toString() + us.uid.toString();
    databaseReference.child("Posts").push().set(data);
  }

  void goToHome() {
    Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => HomePage(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (us.toString() != null.toString()) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          title: Text(
            "New Post",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
          ),
        ),
        body: Container(
          child: Center(
              child: sampleImage.toString() == null.toString()
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            RoundedButton(
                              text: "Open Camera",
                              color: Colors.green,
                              press: () {
                                captureImage();
                              },
                            ),
                            RoundedButton(
                              text: "Choose from Gallery",
                              color: Colors.green[100],
                              textColor: Colors.green,
                              press: () {
                                getImage();
                              },
                            )
                          ],
                        ),
                      ),
                    )
                  : enableUpload()),
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
                            color: Colors.black,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0, bottom: 5),
                            child: Text(
                              "Home",
                              style: TextStyle(color: Colors.black),
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
                            color: Colors.blue,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0, bottom: 5),
                            child: Text(
                              "Post",
                              style: TextStyle(color: Colors.blue),
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

  Widget enableUpload() {
    return SingleChildScrollView(
      child: Container(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2),
            child: Column(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.file(
                        sampleImage,
                        height: 300,
                        width: 600,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              border: Border.all(color: Colors.green[100]),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextFormField(
                                cursorColor: Colors.green,
                                decoration: InputDecoration(
                                  icon: Image.file(sampleImage,
                                      height: 40, width: 40),
                                  hintText: "Write a Caption",
                                  border: InputBorder.none,
                                ),
                                validator: (value) {
                                  return value.isEmpty
                                      ? 'Please Add a Caption'
                                      : null;
                                },
                                onSaved: (value) {
                                  return _myValue = value;
                                },
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Column(children: [
                        RoundedButton(
                          text: "Post",
                          press: uploadImage,
                        ),
                        RoundedButton(
                          text: "Change Photo",
                          press: () {
                            sampleImage = null;
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => UploadNewPost(),
                                ));
                          },
                          textColor: Colors.green,
                          color: Colors.green[100],
                        ),
                      ]),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'components/rounded_button.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadPhoto extends StatefulWidget {
  @override
  _UploadPhotoState createState() => _UploadPhotoState();
}

class _UploadPhotoState extends State<UploadPhoto> {
  File sampleImage;
  String _myValue;
  final formKey = GlobalKey<FormState>();

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      sampleImage = tempImage;
    });
  }

  Future captureImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.camera);
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Row(children: [
            Text("Post"),
          ]),
        ),
        body: Container(
          child: Center(
              child: sampleImage.toString() == null.toString()
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 200),
                      child: Column(
                        children: [
                          RoundedButton(
                            text: "Take a Photo",
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
                    )
                  : enableUpload()),
        ));
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
                          press: validateAndSave,
                        ),
                        RoundedButton(
                          text: "Pick Another Photo",
                          press: () {
                            sampleImage = null;
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => UploadPhoto(),
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

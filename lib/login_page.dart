import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iiitk_app/components/loading.dart';
import 'package:iiitk_app/components/rounded_button.dart';
import 'package:iiitk_app/components/rounded_input_field.dart';
import 'package:iiitk_app/components/rounded_password_field.dart';
import 'package:iiitk_app/home_page.dart';
import 'package:firebase_core/firebase_core.dart';

class LoginHere extends StatefulWidget {
  @override
  _LoginHereState createState() => _LoginHereState();
}

enum FormType { root, login, register }
enum Already { already, none, notchecked }
String error;

class _LoginHereState extends State<LoginHere> {
  //Variables
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final formKey = GlobalKey<FormState>();
  FormType _formType = FormType.root;
  Already _already = Already.notchecked;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String email;
  bool success;

  //Methods:
  void check() async {
    final us = FirebaseAuth.instance.currentUser;
    if (us != null) {
      _already = Already.already;
    } else {
      _already = Already.none;
    }
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

  void validateAndSubmit() async {}

  void moveToRegister() {
    formKey.currentState.reset();

    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToRoot() {
    formKey.currentState.reset();

    setState(() {
      _formType = FormType.root;
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();

    setState(() {
      _formType = FormType.login;
    });
  }

  //Design
  @override
  Widget build(BuildContext context) {
    check();
    if (_already == Already.none) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [logo()] + createButtons() + already()),
              ),
            ),
          ),
        ),
      );
    } else {
      print(_emailController.text);
      return HomePage();
    }
  }

  List<Widget> createinputs() {
    return [
      RoundedInputField(
        hintText: "Your Email",
        onChanged: (value) {},
        controller: _emailController,
      ),
      RoundedPasswordField(
        onChanged: (value) {},
        controller: _passwordController,
      ),
    ];
  }

  List<Widget> already() {
    if (_formType == FormType.login) {
      return [
        FlatButton(
          onPressed: moveToRoot,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(" New Here ? ",
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.blue,
                  )),
              Text("CREATE AN ACCOUNT",
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  )),
            ],
          ),
        ),
      ];
    } else if (_formType == FormType.register) {
      return [
        FlatButton(
          onPressed: moveToRoot,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already have an account?",
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.blue,
                  )),
              Text("LOGIN",
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  )),
            ],
          ),
        ),
      ];
    } else {
      return [];
    }
  }

  Widget logo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50),
      child: Hero(
        tag: 'hero',
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 110,
          child: Image.asset('images/vector.png'),
        ),
      ),
    );
  }

  List<Widget> createButtons() {
    if (_formType == FormType.register) {
      return createinputs() +
          [
            RoundedButton(
              text: "REGISTER",
              press: () async {
                if (validateAndSave()) {
                  try {
                    Dialogs.showLoadingDialog(context, _keyLoader);
                    UserCredential user = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );

                    print(_emailController.text);
                    if (user != null) {
                      Navigator.of(_keyLoader.currentContext,
                              rootNavigator: true)
                          .pop();
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => HomePage()),
                      );
                    }
                  } catch (e) {
                    print(e);
                    Navigator.of(_keyLoader.currentContext, rootNavigator: true)
                        .pop();
                    _passwordController.text = "";
                    _emailController.text = "";
                    // TODO: alertdialog with error
                  }
                }
              },
            ),
          ];
    } else if (_formType == FormType.login) {
      return createinputs() +
          [
            RoundedButton(
              text: "LOGIN",
              press: () async {
                if (validateAndSave()) {
                  try {
                    Dialogs.showLoadingDialog(context, _keyLoader);
                    UserCredential user =
                        (await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passwordController.text,
                    ));

                    if (user != null) {
                      Navigator.of(_keyLoader.currentContext,
                              rootNavigator: true)
                          .pop();
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => HomePage()),
                      );
                    }
                  } catch (e) {
                    print(e);
                    Navigator.of(_keyLoader.currentContext, rootNavigator: true)
                        .pop();
                    _passwordController.text = "";
                    _emailController.text = "";

                    _alertWrongPassword();
                  }
                }
              },
            ),
          ];
    } else {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          child: Text(
            "Hola ! Welcome to IIITK Blog !! ",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(29),
            child: FlatButton(
              color: Colors.green,
              onPressed: moveToLogin,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                child: Text(
                  "LOGIN",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(29),
            child: FlatButton(
              color: Colors.green[100],
              onPressed: moveToRegister,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                child: Text(
                  "REGISTER",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.green),
                ),
              ),
            ),
          ),
        ),
      ];
    }
  }

  Future<void> _alertWrongPassword() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Wrong Email or password'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('The Email or Password you entered is wrong.'),
              ],
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Center(
                    child: TextButton(
                      child: Text('Try Again'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

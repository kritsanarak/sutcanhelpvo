import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sutcanhelpv/apphome.dart';



class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  //Explicit
  final formKey = GlobalKey<FormState>();
  String emailString, passwordString;
  //Method
  Widget sut() {
    return Text(
      'SUT',
      style: TextStyle(
          fontSize: 72.0,
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontFamily: 'Inter'),
    );
  }

  Widget can() {
    return Text(
      'CAN',
      style: TextStyle(
          fontSize: 72.0,
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontFamily: 'Inter'),
    );
  }

  Widget help() {
    return Text(
      'HELP',
      style: TextStyle(
          fontSize: 72.0,
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontFamily: 'Inter'),
    );
  }

  Widget backButton() {
    return IconButton(
      icon: Icon(
        Icons.navigate_before,
        size: 36.0,
        color: Colors.white,
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget okButton() {
    return FlatButton(
      child: Text('OK'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget emailText() {
    return TextFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: 'EMAIL',
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16.0,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(5),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      onSaved: (String value) {
        emailString = value.trim();
      },
    );
  }

  Widget passwordText() {
    return TextFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: 'PASSWORD',
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16.0,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(5),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      onSaved: (String value) {
        passwordString = value.trim();
      },
    );
  }

  Widget showAppName() {
    return Column(
      children: <Widget>[
        sut(),
        can(),
        help(),
      ],
    );
  }

  Widget login() {
    return RaisedButton(
      color: Colors.white,
      child: Text(
        'เข้าสู่ระบบ',
        style: TextStyle(
            fontSize: 30.0,
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontFamily: 'Kanit'),
      ),
      onPressed: () {
        formKey.currentState.save();
        print('email = $emailString,password = $passwordString');
        checkAuthen();
      },
    );
  }

  Future<void> checkAuthen() async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    await firebaseAuth
        .signInWithEmailAndPassword(
            email: emailString, password: passwordString)
        .then((respose) {
      print('Authen Success');
      MaterialPageRoute materialPageRoute =
          MaterialPageRoute(builder: (BuildContext context) => AppHome());
      Navigator.of(context).pushAndRemoveUntil(
          materialPageRoute, (Route<dynamic> rount) => false);
    }).catchError((response) {
      String title = response.code;
      String message = response.message;
      myAlert(title, message);
    });
  }

  Widget showTitle(String title) {
    return ListTile(
        leading: Icon(
          Icons.announcement,
          size: 30,
          color: Colors.red,
        ),
        title: Text(
          title,
          style: TextStyle(
              color: Colors.red,
              fontFamily: 'Kanit',
              fontSize: 18.0,
              fontWeight: FontWeight.bold),
        ));
  }

  void myAlert(String title, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: showTitle(title),
            content: Text(message),
            actions: <Widget>[
              okButton(),
            ],
          );
        });
  }

  Widget content() {
    return Center(
      child: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(15.0),
          children: <Widget>[
            Container(
              height: 32.0,
            ),
            showAppName(),
            Container(
              height: 32.0,
            ),
            emailText(),
            Container(
              height: 15.0,
            ),
            passwordText(),
            Container(
              height: 32.0,
            ),
            login(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.orange,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            backButton(),
            content(),
          ],
        ),
      ),
    );
  }
}

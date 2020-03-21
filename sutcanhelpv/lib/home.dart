import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sutcanhelpv/apphome.dart';
import 'package:sutcanhelpv/login.dart';
import 'package:sutcanhelpv/signup.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
     checkstatus();
  }

  Future<void> checkstatus()async{
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    FirebaseUser  firebaseUser = await firebaseAuth.currentUser();
    if (firebaseUser != null){
      MaterialPageRoute materialPageRoute = MaterialPageRoute(builder: (BuildContext context) => AppHome());
      Navigator.of(context).pushAndRemoveUntil(materialPageRoute, (Route<dynamic> route) => false);
    }
  }

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

  Widget login() {
    return Container(width: 285.0,
      child: OutlineButton(
        color: Colors.orange,
        borderSide: BorderSide(width: 2.0, color: Colors.white),
        child: Text(
          'ลงชื่อเข้าใช้',
          style: TextStyle(
              fontSize: 30.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Kanit'),
        ),
        onPressed: () {
          print('You click Sign up');

          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext context) => Login());
          Navigator.of(context).push(materialPageRoute);
        },
      ),
    );
  }

  Widget signUp() {
    return Container(width: 285.0,
      child: RaisedButton(
        color: Colors.white,
        child: Text(
          'สมัครสมาชิก',
          style: TextStyle(
              fontSize: 30.0,
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontFamily: 'Kanit'),
        ),
        onPressed: () {
          print('You click SignUp');
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext context) => SignUp());
          Navigator.of(context).push(materialPageRoute);
        },
      ),
    );
  }

  Widget showButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        login(),
        SizedBox(
          height: 8.0,
        ),
        signUp(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(
              height: 50.0,
            ),
            sut(),
            can(),
            help(),
            SizedBox(
              height: 150.0,
            ),
            showButton(),
          ],
        ),
      )),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sutcanhelpv/apphome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final formKey = GlobalKey<FormState>();
  String userString,
      passString,
      nameString,
      idcardInt,
      currentUser,
      userUid,
      selected;
  final databaseReference = Firestore.instance;
  List<DropdownMenuItem<String>> listDrop = [];
  void loadData() {
    listDrop = [];
    listDrop.add(new DropdownMenuItem(
      child: new Text(
        'ชาย',
        style: TextStyle(fontFamily: 'kanit', fontSize: 18.0),
      ),
      value: 'ชาย',
    ));
    listDrop.add(new DropdownMenuItem(
      child: new Text(
        'หญิง',
        style: TextStyle(fontFamily: 'kanit', fontSize: 18.0),
      ),
      value: 'หญิง',
    ));
  }

  void myAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('แจ้งเตือน'),
              content: Text('กรุณาเลือกเพศ'),
              actions: <Widget>[
                okButton(),
              ]);
        });
  }

  Widget okButton() {
    return FlatButton(
      child: Text('OK'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget sut() {
    return Center(
      child: Text(
        'สมัครสมาชิก',
        style: TextStyle(
            fontSize: 43.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Kanit'),
      ),
    );
  }

  Widget username() {
    return TextFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: 'username',
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16.0,
        ),
      ),
      validator: (String value) {
        if (!(value.contains('@') && (value.contains('.')))) {
          return 'Please Enter Your Email';
        } else {
          return null;
        }
      },
      onSaved: (String value) {
        userString = value;
      },
    );
  }

  Widget password() {
    return TextFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: 'password',
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16.0,
        ),
      ),
      validator: (String pass) {
        if (pass.length < 8) {
          return 'Please Enter Your Password';
        } else {
          return null;
        }
      },
      onSaved: (String pass) {
        passString = pass;
      },
    );
  }

  Widget name() {
    return TextFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: 'name',
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16.0,
        ),
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please Enter Your Name';
        } else {
          return null;
        }
      },
      onSaved: (String value) {
        nameString = value;
      },
    );
  }

  Widget idcard() {
    return TextFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: 'idcard',
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16.0,
        ),
      ),
      validator: (String value) {
        if (value.length != 13) {
          return 'Please Enter Your Email';
        } else {
          return null;
        }
      },
      onSaved: (String value) {
        idcardInt = value;
      },
    );
  }

  Widget gender() {
    return Center(
      child: DropdownButton(
          items: listDrop,
          value: selected,
          icon: Icon(Icons.account_circle),
          iconSize: 35.0,
          hint: Text(
            'เลือกเพศ',
            style: TextStyle(
                fontFamily: 'kanit',
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          onChanged: (value) {
            selected = value;
            setState(() {});
          }),
    );
  }

  Widget login() {
    return RaisedButton(
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
        if (formKey.currentState.validate()) {
          formKey.currentState.save();
          print(
            'Username = $userString, password = $passString, name = $nameString, idcard = $idcardInt',
          );
          registerThread();
        }
      },
    );
  }

  Future<void> registerThread() async {
    if (selected != null) {
      FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      await firebaseAuth
          .createUserWithEmailAndPassword(
              email: userString, password: passString)
          .then((response) {
        setupUser();

        print('Register Success for Email = $userString');
        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext context) => AppHome());
        Navigator.of(context).pushAndRemoveUntil(
            materialPageRoute, (Route<dynamic> route) => false);
      }).catchError((response) {
        String title = response.code;
        String message = response.message;
        print('title = $title, message = $message');
      });
    }
  }

  Future<void> setupUser() async {
      final FirebaseUser user = await FirebaseAuth.instance.currentUser();
      userUid = user.uid.toString();
       await databaseReference.collection("Volunteers")
      .document(userUid)
      .setData({
        'Email': userString,
        'Name': nameString,
        'IdCard' : idcardInt,
        'Gender' : selected,
      });
  }

  @override
  Widget build(BuildContext context) {
    loadData();
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.orange,
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(15.0),
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            sut(),
            SizedBox(
              height: 15.0,
            ),
            username(),
            SizedBox(
              height: 15.0,
            ),
            password(),
            SizedBox(
              height: 15.0,
            ),
            name(),
            SizedBox(
              height: 15.0,
            ),
            idcard(),
            SizedBox(
              height: 15.0,
            ),
            gender(),
            SizedBox(
              height: 15.0,
            ),
            login(),
            SizedBox(
              height: 15.0,
            ),
          ],
        ),
      ),
    );
  }
}

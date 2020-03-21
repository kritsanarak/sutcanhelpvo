import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sutcanhelpv/profile.dart';
import 'package:sutcanhelpv/home.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';


class AppHome extends StatefulWidget {
  @override
  _AppHomeState createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Widget page = AppHome();
  String emailLogin = 'TEST';
  String name = '';
  String uids = '';
  String profileUrl;
  final databaseReference = Firestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  List<Message> messagesList;
  String _message = '';
  String x ='';
  String _appBadgeSupported='';
  

  //Explicit

  // Method
  _getToken(){
    _firebaseMessaging.getToken().then((deviceToken) {
      print("Device Token: $deviceToken");
    });
  }
 
_configureFirebaseListeners() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
        _setMessage(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
        _setMessage(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
        _setMessage(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true),
    );
}
  _setMessage(Map<String, dynamic> message) {
    final notification = message['notification'];
    final data = message['data'];
    final String title = notification['title'];
    final String body = notification['body'];
    String mMessage = data['message'];
    print("Title: $title, body: $body, message: $mMessage");
    setState(() {
      Message msg = Message(title, body, mMessage);
      messagesList.add(msg);
    });
}

  @override
  void initState() {
    super.initState();
    findDisplayName();
    loadData();
    showDrawer();
    messagesList = List<Message>();
    _getToken();
    _configureFirebaseListeners();
    initPlatformState();
    
   
    
   }
   initPlatformState() async {
    String appBadgeSupported;
    
      bool res = await FlutterAppBadger.isAppBadgeSupported();
      if (res) {
        appBadgeSupported = 'Supported';
      } else {
        appBadgeSupported = 'Not supported';
      }
   

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _appBadgeSupported = appBadgeSupported;
    });
  }
   void _addBadge() {
    FlutterAppBadger.updateBadgeCount(3);
    
  }

  
  Future<void> loadData() async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    FirebaseUser firebaseUser = await firebaseAuth.currentUser();
    String uids = firebaseUser.uid;
    final DocumentReference documentReference =
        Firestore.instance.document('Volunteers/$uids');
    documentReference.get().then((datasnapshot) {
      if (datasnapshot.exists) {
        setState(() {
          name = datasnapshot.data['Name'];
          profileUrl = datasnapshot.data['Photo'];
          print('Name = $name /t URL = $profileUrl');
        });
      }
    });
  }

  //Stream<DocumentSnapshot> name = databaseReference.collection('Volunteers').document(uids).snapshots();

  Widget showProfile() {
    return ListTile(
        
        leading: Icon(Icons.person),
        title: Text(
          'ข้อมูลส่วนตัว',
          style: TextStyle(
              fontFamily: 'kanit', fontSize: 15.0, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          setState(() {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Profile()));
          });
        });
  }

  Widget showAvatar() {
    if (profileUrl != 'null') {
      return CircleAvatar(
        radius: 50.0,
        backgroundColor: Color(0xFFFf9800),
        child: ClipOval(
          child: SizedBox(
              width: 100.0, height: 100.0, child: Image.network('$profileUrl')),
        ),
      );
    }
    else{
      return CircleAvatar(
        radius: 50.0,
        backgroundColor: Color(0xFFFf9800),
        
      );
    }
  
    
  }

  Widget showEmailLogin() {
    return Text(
      "คุณ $name",
      style: TextStyle(
          fontSize: 20.0,
          color: Colors.white,
          fontFamily: 'kanit',
          fontWeight: FontWeight.bold),
    );
  }

  Widget showNameLogin() {
    return Text(
      '$name',
      style: TextStyle(
          fontSize: 20.0,
          color: Colors.white,
          fontFamily: 'kanit',
          fontWeight: FontWeight.bold),
    );
  }

  Widget showHeader() {
    return DrawerHeader(
      child: Column(
        children: <Widget>[
          showAvatar(),
        
          showEmailLogin(),
        ],
      ),
      decoration: BoxDecoration(color: Colors.orange),
    );
  }

  Widget showDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(0.0),
        children: <Widget>[
          showHeader(),
          showProfile(),
        ],
      ),
      
    );
  }

  Future<void> findDisplayName() async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    FirebaseUser firebaseUser = await firebaseAuth.currentUser();
    setState(() {
      emailLogin = firebaseUser.email;
      uids = firebaseUser.uid;
    });
    return emailLogin;
  }

  Widget signOutBt() {
    return IconButton(
      icon: Icon(Icons.exit_to_app),
      tooltip: 'Sign Up',
      onPressed: () {
        myAlert();
      },
    );
  }

  Widget buttomshow() {
    return FlatButton(
      child: Text('Click'),
      onPressed: () {
        loadData();
      },
    );
  }

  void myAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Are You Sure'),
              content: Text('Do You Want Sign Out'),
              actions: <Widget>[
                cancleButton(),
                okButton(),
              ]);
        });
  }

  Widget okButton() {
    return FlatButton(
      child: Text('OK'),
      onPressed: () {
        Navigator.of(context).pop();
        processSignout();
      },
    );
  }

  Future<void> processSignout() async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    await firebaseAuth.signOut().then((response) {
      MaterialPageRoute materialPageRoute =
          MaterialPageRoute(builder: (BuildContext context) => Home());
      Navigator.of(context).pushAndRemoveUntil(
          materialPageRoute, (Route<dynamic> route) => false);
    });
  }

  Widget cancleButton() {
    return FlatButton(
      child: Text('Cancle'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
  String textValue = 'Hello world';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: AppBar(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.0))),
        backgroundColor: Colors.orange,
        actions: <Widget>[
          
        ],
      ),

      drawer: showDrawer(),
      drawerScrimColor: Colors.white,
    body: ListView.builder(
        itemCount: null == messagesList ? 0 : messagesList.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                messagesList[index].message,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  
                ),
              ),
              ),
            );
          },

            ),
        
    );
  }
}
class Message {
  String title;
  String body;
  String message;
  Message(title, body, message) {
    this.title = title;
    this.body = body;
    this.message = message;
  }
}

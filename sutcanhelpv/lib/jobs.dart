import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sutcanhelpv/profile.dart';
import 'package:sutcanhelpv/home.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:map_launcher/map_launcher.dart';

class Jobs extends StatefulWidget {
  @override
  _JobsState createState() => _JobsState();
}

class _JobsState extends State<Jobs> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Widget page = Jobs();
  String emailLogin = 'TEST';
  String name = '';
  String uids = '';
  String profileUrl;
  final databaseReference = Firestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  List<Message> messagesList;
  String _message = '';
  String x = '';
  String _appBadgeSupported = '';
  String userUid ;
  

  //mapp
  openMapsSheet(context,lat) async {
    try {
      var str = lat.split(",");
      var lattitude = str[0].substring(7);
      var longtitude = str[1].substring(1);
      var longtitude2 = longtitude.split(")");
      print(lattitude);
      print(longtitude2[0]);
      var x = double.parse(lattitude);
      var y = double.parse(longtitude2[0]);
      final title = "Ambulance";
      final description = "Asia's tallest building";
      final coords = Coords(x, y);
      final availableMaps = await MapLauncher.installedMaps;

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                child: Wrap(
                  children: <Widget>[
                    for (var map in availableMaps)
                      ListTile(
                        onTap: () => map.showMarker(
                          coords: coords,
                          title: title,
                          description: description,
                        ),
                        title: Text(map.mapName),
                        leading: Image(
                          image: map.icon,
                          height: 30.0,
                          width: 30.0,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }
  //Explicit

  // Method
  _getToken() {
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
  Widget showJobs() {
    return ListTile(
        leading: Icon(Icons.person),
        title: Text(
          'งานที่รับ',
          style: TextStyle(
              fontFamily: 'kanit', fontSize: 15.0, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          setState(() {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Jobs()));
          });
        });
  }
   Future<void> setupUser(detail,image1,image2,image3,position,timestamp,user,symptom,id) async {
    
  
        await databaseReference.collection('SOS').document(id).delete();
       await databaseReference.collection("AcceptSOS")
      .document()
      .setData({
        'Detail': detail,
        'ImageSOS_1': image1,
        'ImageSOS_2' : image2,
        'ImageSOS_3' : image3,
        'Position' : position,
        'Timestamp' : timestamp,
        'User' : user,
        'อาการ' : symptom,
        'Volunteer': uids,
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
    } else {
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
          showJobs(),
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
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(20.0))),
          backgroundColor: Colors.orange,
          actions: <Widget>[],
        ),
        drawer: showDrawer(),
        drawerScrimColor: Colors.white,
        body: StreamBuilder(
            stream: Firestore.instance.collection('AcceptSOS').where('Volunteer', isEqualTo: uids).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                const Text('Loading');
              } else {
                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                  
                   DocumentSnapshot sos = snapshot.data.documents[index];
                   
                    return Stack(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 350.0,
                          child: Padding(
                            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Material(
                              color: Colors.white,
                              elevation: 14.0,
                              shadowColor: Color(0x802196F3),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(children: <Widget>[
                                    Container(width: MediaQuery.of(context).size.width,height: 200.0,
                                    child: Image.network(
                                      '${sos['ImageSOS_1']}',
                                      fit:BoxFit.fill
                                    ),
                                    ),
                                   
                                    SizedBox(height: 10.0,),
                                    Text('${sos['อาการ']}',
                                    style: TextStyle( fontSize: 20.0,fontWeight: FontWeight.bold,color:Colors.blueGrey),
                                    ),
                              
                                    SizedBox(height: 10.0,),
                                    RaisedButton(color: Colors.green,child: Text('รับงาน'),
                                    onPressed: () { 
                                    
                                    openMapsSheet(context,sos['Position'],);
                                    
                                    
                                    }
                                    )
                                  ],),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                   
                  },
                );
              }
            }));
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

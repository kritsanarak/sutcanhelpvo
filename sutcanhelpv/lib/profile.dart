import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:image_cropper/image_cropper.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File _image;

  String emailLogin = '...';
  String name = '...';
  String uids = '';
  String pullURL = '';
  FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;


  @override
  void initState() {
    super.initState();
    findDisplayName();
    getdata();
  }

  Widget showLogoActor() {
    if (_image != null) {
      return Image.file(_image, fit: BoxFit.fill);
    } 
   else {
      return Container(
        width: 200.0,
        height: 200.0,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage('images/logoActor.jpg'),
              fit: BoxFit.fill,
            )),
      );
    }
  }

  Widget showEmailLogin() {
    return Text(
      '$emailLogin',
      style: TextStyle(fontSize: 30.0, color: Colors.white),
    );
  }

  Widget showNameLogin() {
    return Text(
      '$name',
      style: TextStyle(fontSize: 30.0, color: Colors.white),
    );
  }

  Widget logoCircle() {
    return CircleAvatar(
      radius: 70.0,
      backgroundColor: Colors.blue[900],
      child: ClipOval(
        child: SizedBox(width: 120.0, height: 120.0, child: showLogoActor()
            //     ? Image.file(_image, fit: BoxFit.fill)
            //     // ? Image.network(
            //     //     pullURL1,
            //     //     fit: BoxFit.fill,
            //     //   )
            //     : showLogoActor()
            // // : Image.network(
            // //     'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQQJR6BqqLi6y004j182y-DQqexGNssQn5AHlZ7DUBXpYQe3H7P&s',
            // //     fit: BoxFit.fill,
            // //   ),
            ),
      ),
    );
  }

  Widget buttonupdatePhoto() {
    return IconButton(
      icon: Icon(Icons.camera),
      onPressed: () {
        getImage();
      },
      iconSize: 30.0,
    );
  }

  void getdata() async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    FirebaseUser firebaseUser = await firebaseAuth.currentUser();
    setState(() {
      String uids = firebaseUser.uid;
    final DocumentReference documentReference =
        Firestore.instance.document('Volunteers/$uids');
    documentReference.get().then((datasnapshot) {
      if (datasnapshot.exists) {
        setState(() {
          name = datasnapshot.data['Name'];
          pullURL = datasnapshot.data['URL'];
          print('Name = $name /t URL = $pullURL');
        });
      }
    });
    
    });
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

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    print(image.lengthSync());
    // File croppedFile = await ImageCropper.cropImage(
    //     sourcePath: image.path,
    //     compressQuality: 30,
    //     maxHeight: 200,
    //     maxWidth: 200,
    //     cropStyle: CropStyle.circle,
    //     aspectRatioPresets: [
    //       CropAspectRatioPreset.square,
    //       CropAspectRatioPreset.ratio3x2,
    //       CropAspectRatioPreset.original,
    //       CropAspectRatioPreset.ratio4x3,
    //       CropAspectRatioPreset.ratio16x9
    //     ],
    //     androidUiSettings: AndroidUiSettings(
    //         toolbarTitle: 'Cropper',
    //         toolbarColor: Colors.deepOrange,
    //         toolbarWidgetColor: Colors.white,
    //         initAspectRatio: CropAspectRatioPreset.square,
    //         lockAspectRatio: false),
    //     iosUiSettings: IOSUiSettings(
    //       minimumAspectRatio: 1.0,
    //     ));
    setState(() {
      _image = image;
      print("Impge Patn $_image");
    });
  }

  Future uploadPhoto(BuildContext context) async {
    // String filName = basename(_image.path);
    print(_image.lengthSync());

    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('ProfileVolunteer').child(uids);

    StorageUploadTask storageUploadTask = firebaseStorageRef.putFile(_image);
    // StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;
    var downUrl =
        await (await storageUploadTask.onComplete).ref.getDownloadURL();
    var url = downUrl.toString();
    print("Download URL $url");
    setURLImage(url);
    setState(() {
      print("Profile Picture update");
      // pullURL = url;
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Profile Picture Update"),
      ));
    });
  }

  Future<void> setURLImage(url) async {
    // final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    var uids = user.uid.toString();
    final DocumentReference documentReference =
        Firestore.instance.document('Volunteers/$uids');
    Map<String, String> data = <String, String>{"Photo": url};
    documentReference.updateData(data).whenComplete(() {
      setState(() {
        pullURL = url;
        print('Update URL image To $uids and Sucess');
      });
    }).catchError((e) => print(e));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: 'back',
          onPressed: () {
            // MaterialPageRoute materialPageRoute =
            //     MaterialPageRoute(builder: (BuildContext context) => Home());
            // Navigator.of(context).pushAndRemoveUntil(
            //     materialPageRoute, (Route<dynamic> route) => false);
          },
        ),
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(Icons.ac_unit),
        //     tooltip: 'back',
        //     onPressed: () {
        //       MaterialPageRoute materialPageRoute =
        //           MaterialPageRoute(builder: (BuildContext context) => Home());
        //       Navigator.of(context).pushAndRemoveUntil(
        //           materialPageRoute, (Route<dynamic> route) => false);
        //     },
        //   ),
        // ],
      ),
      body: Builder(
        builder: (context) => Container(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                logoCircle(),
                Padding(
                  padding: const EdgeInsets.only(top: 90.0),
                  child: buttonupdatePhoto(),
                )
              ],
            ),
            SizedBox(height: 20.0),
            showEmailLogin(),
            showNameLogin(),
            RaisedButton(onPressed: () {
              uploadPhoto(context);
            }),
          ],
        )),
      ),
      // bottomNavigationBar: BottomNavigationProfile()
    );
  }
}

//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.lightBlueAccent,
//       appBar: AppBar(
//           // title: Text('ssss'),
//           ),
//       body: ListView(

//         children: <Widget>[
//           Column(
//             children: <Widget>[
//               showLogoActor(),
//               showNameLogin(),
//               showEmailLogin(),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
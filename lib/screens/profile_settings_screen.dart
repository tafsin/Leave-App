import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:image_picker/image_picker.dart';

import '../helper/customFunction.dart';

class Profile_Settings extends StatefulWidget {
  const Profile_Settings({Key? key}) : super(key: key);

  @override
  _Profile_SettingsState createState() => _Profile_SettingsState();
}

class _Profile_SettingsState extends State<Profile_Settings> {
  //GlobalMethods _globalMethods = GlobalMethods();
  File? _pickedImage;
  String? userEmail = '';
  String url = "";
  String uid = '';
  void initState() {
    super.initState();

    currentUsr();
  }

  void dispose() {
    Loader.hide();
    super.dispose();
  }

  void currentUsr() {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      userEmail = currentUser.email;
      uid = currentUser.uid;
    }
  }

  void _pickedImageCamera() async {
    final picker = ImagePicker();
    final pickedIamge =
        await picker.getImage(source: ImageSource.camera, imageQuality: 10);
    final pickedImageFile = File(pickedIamge!.path);

    setState(() {
      _pickedImage = pickedImageFile;
    });
    Navigator.pop(context);
  }

  void _pickedImageGallery() async {
    final picker = ImagePicker();
    final pickedImage =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 10);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    Navigator.pop(context);
  }

  void _remove() {
    setState(() {
      _pickedImage = null;
    });
    Navigator.pop(context);
  }

  _saveImage() async {
    try {
      Loader.show(context);
      final ref = FirebaseStorage.instance
          .ref()
          .child('usersImage')
          .child(userEmail! + '.jpg');
      await ref.putFile(_pickedImage!);
      url = await ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'imageUrl': url});

      Loader.hide();
    } catch (e) {
      Loader.show(context);
      print(e);
      Loader.hide();
    }
  }

  showMessage() {
    if (_pickedImage != null) {
      showAlertDialog(context);
    } else {
      showAlertDialogNull(context);
    }
  }

  showAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = ElevatedButton(
      child: Text("OK"),
      onPressed: () async {
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Profile picture uploaded"),
      content: Text(""),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialogNull(BuildContext context) {
    // Create button
    Widget okButton = ElevatedButton(
      child: Text("OK"),
      onPressed: () async {
        Navigator.pop(context);
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("You Did Not Select Any Picture"),
      content: Text(""),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: customDecorationBox(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).padding.top,
            ),
            Row(
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back)),
                Expanded(
                  child: Center(
                    child: Text(
                      'Profile Settings',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SizedBox(
                //   width: 50,
                // ),
                Stack(
                  children: [
                    Container(
                      //color: Colors.grey,
                      margin:
                          EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.black87,
                        child: CircleAvatar(
                          //foregroundColor: Colors.white,
                          backgroundColor: Colors.grey,
                          radius: 66,

                          backgroundImage: _pickedImage == null
                              ? null
                              : FileImage(_pickedImage!),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 120,
                      left: 120,
                      child: RawMaterialButton(
                        elevation: 10,
                        fillColor: Colors.blueGrey,
                        child: Icon(Icons.add_a_photo),
                        padding: EdgeInsets.all(15),
                        shape: CircleBorder(),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Choose Option'),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            _pickedImageCamera();
                                          },
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Icon(Icons.camera),
                                              ),
                                              Text('Camera')
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            _pickedImageGallery();
                                          },
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Icon(Icons.image),
                                              ),
                                              Text('Gallery')
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            _remove();
                                          },
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child:
                                                    Icon(Icons.remove_circle),
                                              ),
                                              Text('Remove')
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
            ElevatedButton(
         style: ElevatedButton.styleFrom(
           primary: Colors.blue, // background

           shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(25)),
         ),
              onPressed: () async {
                await _saveImage();
                showMessage();
                //showAlertDialog(context);
              },
              child: Text("upload",style: TextStyle(color: Colors.white),),
            ),
            SizedBox(
              height: 20,
            ),

          ],
        ),
      ),
    );
  }
}

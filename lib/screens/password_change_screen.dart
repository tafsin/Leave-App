import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:ttz_leave_application_demo/screens/login_screen.dart';

class Password_Change extends StatefulWidget {
  const Password_Change({Key? key}) : super(key: key);

  @override
  _Password_ChangeState createState() => _Password_ChangeState();
}

class _Password_ChangeState extends State<Password_Change> {
  final passwordEditingController = TextEditingController();
  final confirmPasswordEditingController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final currentUser = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  //
  // void currentUsr() {
  //   var currentUser = FirebaseAuth.instance.currentUser;
  //   if (currentUser != null) {
  //     userId = currentUser.uid;
  //     print('current user $userId');
  //     //roleStream();
  //   }
  // }
  changePassword() async {
    var user = FirebaseAuth.instance.currentUser;

    await user?.updatePassword(passwordEditingController.text).then((_) {
      print("Successfully changed password");
    }).catchError((error) {
      print("Password can't be changed" + error.toString());
      //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
    });
  }

  @override
  void dispose() {
    Loader.hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passwordField = TextFormField(
      style: TextStyle(color: Colors.white),
      autofocus: false,
      controller: passwordEditingController,
      onSaved: (value) {
        passwordEditingController.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.vpn_key,
          color: Colors.white,
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: 'Enter Your Password',
        hintStyle: TextStyle(color: Colors.white),
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      validator: (value) {
        RegExp regex = new RegExp(r'^.{6,}$');
        if (value!.isEmpty) {
          return "Password cannot be empty";
        }
        if (!regex.hasMatch(value)) {
          return ("please enter valid password min. 6 character");
        } else {
          return null;
        }
      },
    );
    final confirmPasswordField = TextFormField(
      style: TextStyle(color: Colors.white),
      autofocus: false,
      controller: confirmPasswordEditingController,
      onSaved: (value) {
        passwordEditingController.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.vpn_key,
          color: Colors.white,
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: 'Confirm Your Password',
        hintStyle: TextStyle(color: Colors.white),
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      validator: (value) {
        if (confirmPasswordEditingController.text !=
            passwordEditingController.text) {
          return "Password did not match";
        } else {
          return null;
        }
      },
    );
    final changeButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.blue,
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            Loader.show(context);
            await changePassword();
            Loader.hide();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Login_Page()),
            );
          }
        },
        child: Text(
          'Change password',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
    return Scaffold(
      backgroundColor: Color(0xff0a0e21),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Text(
                    //   'TechTrioz Solution',
                    //   style: TextStyle(
                    //       fontSize: 30,
                    //       fontWeight: FontWeight.bold,
                    //       color: Colors.lightBlue),
                    // ),
                    SizedBox(
                      height: 20.0,
                    ),
                    passwordField,
                    SizedBox(
                      height: 20.0,
                    ),
                    confirmPasswordField,
                    SizedBox(
                      height: 20.0,
                    ),
                    changeButton,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

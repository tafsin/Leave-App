import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:ttz_leave_application_demo/all_employee_leave.dart';
import 'package:ttz_leave_application_demo/model.dart';
import 'package:ttz_leave_application_demo/screens/login_screen.dart';

import '../helper/customFunction.dart';

class Registration_Page extends StatefulWidget {
  const Registration_Page({Key? key}) : super(key: key);

  @override
  _Registration_PageState createState() => _Registration_PageState();
}

class _Registration_PageState extends State<Registration_Page> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  CollectionReference ref = FirebaseFirestore.instance.collection('users');
  final nameEditingController = TextEditingController();
  final emailEditingController = TextEditingController();
  final passwordEditingController = TextEditingController();
  final confirmPasswordEditingController = TextEditingController();
  int? leaveNum = 20;
  int? leaveTakenNum = 0;
  int? balanceLeave = 20;
  int? sickLeaveTaken = 0;
  // String? employeeName = "";
  // String? userEmail;
  // String uid = '';
  // var options = [
  //   'Employee',
  //   'Admin',
  // ];
  //var _currentItemSelected = "Employee";
  var role = "Employee";
  bool isActive = true;
  bool isEmployee = true;
  bool isSuperUser = false;
  bool isApprover = false;

  postDetailsToFirestore(String email, String role, String name) async {
    print('postUsers');
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    UserModel userModel = UserModel();
    userModel.email = email;
    userModel.uid = user!.uid;
    userModel.role = role;
    userModel.name = name;

    userModel.isEmployee = isEmployee;
    userModel.isSuperUser = isSuperUser;
    userModel.isApprover = isApprover;
    userModel.isActive = isActive;
    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());




      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => Login_Page()),
      // );

  }

  postValuesToEmployeeLeave(String email, String name, int? leaveNum,
      int? leaveTakenNum, int? sickLeaveTaken, int? balanceLeave) async {
    print('postEmployeeValue');
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    AllEmployeeLeave employeeLeaveTable = AllEmployeeLeave();
    employeeLeaveTable.userEmail = email;
    employeeLeaveTable.uid = user!.uid;
    employeeLeaveTable.employeeName = name;
    employeeLeaveTable.leaveNum = leaveNum;
    employeeLeaveTable.leaveTakenNum = leaveTakenNum;
    employeeLeaveTable.sickLeaveTaken = sickLeaveTaken;
    employeeLeaveTable.balanceLeave = balanceLeave;
    employeeLeaveTable.isActive = isActive;
    await firebaseFirestore
        .collection("employee_leave")
        .doc(user.uid)
        .set(employeeLeaveTable.toMap());

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (c) => Login_Page()),
            (route) => false);

  }



  @override
  void dispose() {
    Loader.hide();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nameField = TextFormField(
      style: TextStyle(color: Colors.white),
      autofocus: false,
      controller: nameEditingController,
      keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        nameEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.person,
          color: Colors.white,
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: 'Enter Your Name',
        hintStyle: TextStyle(color: Colors.white),
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your name';
        }
        return null;
      },
    );
    final emailField = TextFormField(
      style: TextStyle(color: Colors.white),
      autofocus: false,
      controller: emailEditingController,
      keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        emailEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.mail,
          color: Colors.white,
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: 'Enter Your Email',
        hintStyle: TextStyle(color: Colors.white),
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      validator: (value) {
        if (value!.length == 0) {
          return "Email cannot be empty";
        }
        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
          return ("Please enter a valid email");
        } else {
          return null;
        }
      },
    );
    final passwordField = TextFormField(
      style: TextStyle(color: Colors.white),
      autofocus: false,
      obscureText: true,
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
      obscureText: true,
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
    final signupButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.blue,
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () async {
          print('sign up pressed');
          if (_formKey.currentState!.validate()) {
            Loader.show(context);
            try {
             await _auth
                  .createUserWithEmailAndPassword(
                      email: emailEditingController.text,
                      password: passwordEditingController.text)
                  .then((value) async {
               await postDetailsToFirestore(emailEditingController.text, role,
                    nameEditingController.text);
                  await postValuesToEmployeeLeave(
                      emailEditingController.text,
                      nameEditingController.text,
                      leaveNum,
                      leaveTakenNum,
                      sickLeaveTaken,
                      balanceLeave);

                Loader.hide();
              });
            } catch (e) {
              print(e);
              errorAlert(context, e.toString());
              Loader.hide();
            }
          }
        },
        child: Text(
          'SignUp',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
    return Scaffold(
      backgroundColor: Color(0xff0a0e21),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Registration",
                      style: TextStyle(
                          fontSize: 30.0,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    nameField,
                    SizedBox(
                      height: 10.0,
                    ),
                    emailField,
                    SizedBox(
                      height: 10.0,
                    ),
                    passwordField,
                    SizedBox(
                      height: 10.0,
                    ),
                    confirmPasswordField,
                    SizedBox(
                      height: 20.0,
                    ),
                    signupButton,
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:ttz_leave_application_demo/helper/customFunction.dart';
import 'package:ttz_leave_application_demo/screens/SA_screen.dart';
import 'package:ttz_leave_application_demo/screens/employee_dashboard.dart';
import 'package:ttz_leave_application_demo/screens/forgot_password_screen.dart';
import 'package:ttz_leave_application_demo/screens/registration_screen.dart';
import 'package:ttz_leave_application_demo/screens/supervisor_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'admin_screen.dart';

class Login_Page extends StatefulWidget {
  const Login_Page({Key? key}) : super(key: key);

  @override
  _Login_PageState createState() => _Login_PageState();
}

class _Login_PageState extends State<Login_Page> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  //String roleType = 'a';
  String userId = '';

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  //String myId = '';

  //User user = FirebaseAuth.instance.currentUser;
  // final Stream<QuerySnapshot> user =
  //     FirebaseFirestore.instance.collection('users').snapshots();
  // void getRole() async {
  //   final Stream<QuerySnapshot> user =
  //       FirebaseFirestore.instance.collection('users').snapshots();
  //   stream: user;
  //   builder:(
  //   BuilderContext context,
  //       AsyncSnapshots<Oery>
  //   );
  //   // final roles = await firestore.collection("users").get();
  //   // DocumentSnapshot document = roles.getResult();
  //   // print("role");
  //   // print(roles);
  // }

  currentUsr()  async{
    var currentUser =  FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      userId = currentUser.uid;
      print('current user $userId');
      //roleStream();
       await isValidUser();
      print('current user is Active $isActive');
    }
  }

  bool isActive =false;

  Future<String> roleStream() async {
    var rType = '';
    bool isEmployee = false;
    bool isApprover = false;
    bool isSuperUser = false;
    try {
      final messages = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: userId)
          .get();
      for (var message in messages.docs) {
        var role = message.data();
        print(message.data());
        isEmployee = role['isEmployee'];
        isApprover = role['isApprover'];
        isSuperUser = role['isSuperUser'];
        // setState(() {
        //   isActive = role['isActive'];
        // });
        if(isApprover == true && isSuperUser == true){
          rType = 'SA';
        }
        else if(isSuperUser == true){
          rType = 'superuser';
        }
        else if(isApprover == true){
          rType = 'approver';
        }
        else{
          rType = 'employee';
        }


        //rType = role['role'];


        print('roleStream $rType');
      }
    } catch (e) {
      print(e);
    }
    return rType;
  }

  void userChange() {
    FirebaseAuth.instance.userChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }

  //bool isActive = false;
  isValidUser() async{
    print('isValid');
    final user = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if(user!= null){
      var userData = user.data();
    if(mounted){
      setState(() {
        isActive = userData!['isActive'];
      });
    }
    }
    print('IS VALID USER $isActive');


  }

  @override
  void dispose() {
    Loader.hide();
    super.dispose();
  }
  // void initState(){
  //   super.initState();
  //   FirebaseAuth.instance.userChanges().listen((User? user) async {
  //     if (user == null) {
  //       Loader.show(context);
  //       print('user null');
  //       Navigator.pushReplacement(
  //           context, MaterialPageRoute(builder: (context) => Login_Page()));
  //       Loader.hide();
  //     }
  //     else{
  //
  //     }
  //     });
  // }

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      autofocus: false,
      style: TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        emailController.text = value!;
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
    );
    final passwordField = TextFormField(
      style: TextStyle(color: Colors.white),
      autofocus: false,
      obscureText: true,
      validator: MultiValidator(
        [
          RequiredValidator(errorText: "required"),
        ],
      ),
      controller: passwordController,
      onSaved: (value) {
        passwordController.text = value!;
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
    final loginButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.blue,
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () async {
          Loader.show(context);
          print('login button pressed');

          try {
            final user = await _auth.signInWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);
            print(user);
            userChange();

            if (user != null) {
              print('user not null');
              await currentUsr();
              print("login button $isActive");


              if(isActive){
                var roleType = await roleStream();
                print('login $roleType');
                print('login $isActive $roleType');
                if (roleType == 'SA') {
                  print('if');
                  Loader.hide();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SA_Screen()),
                  );
                }
                else if (roleType == 'approver') {
                  print('else');
                  Loader.hide();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Admin_Page()),
                  );
                }
                else if (roleType == 'superuser') {
                  print('else');
                  Loader.hide();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Supervisor_Screen()),
                  );
                }
                else if (roleType == 'employee'){
                  print('else');
                  Loader.hide();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Employee_Dashboard()),
                  );
                }
              }
              else errorAlert(context, 'Login User Not Found');
            }
          } catch (e) {
            print(e);
            errorAlert(context, e.toString());
            Loader.hide();
          }

          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => Leave_Application_Page()),
          // );
        },
        child: Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
    return Scaffold(
      backgroundColor: Color(0xff0a0e21),
      // appBar: AppBar(
      //   title: Text(
      //     'Welcomo to TechTrioz',
      //     style: TextStyle(
      //       fontSize: 20.0,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      // ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            //color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      height: 220,
                      width: 220,
                      child: Image(
                        image: AssetImage('assets/images/TTZ-logo.png'),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'TechTrioz Leave Management',
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlue,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    emailField,
                    SizedBox(
                      height: 30.0,
                    ),
                    passwordField,
                    SizedBox(
                      height: 30.0,
                    ),
                    loginButton,
                    SizedBox(
                      height: 30.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(fontSize: 15.0, color: Colors.white),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Registration_Page()),
                            );
                          },
                          child: Text(
                            'Signup',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Forgot_Password()),
                        );
                      },
                      child: Text(
                        'Forget Password',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
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

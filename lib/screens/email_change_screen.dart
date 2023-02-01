import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:ttz_leave_application_demo/screens/login_screen.dart';

class Email_Change extends StatefulWidget {
  const Email_Change({Key? key}) : super(key: key);

  @override
  _Email_ChangeState createState() => _Email_ChangeState();
}

class _Email_ChangeState extends State<Email_Change> {
  final emailEditingController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String uid ='';
  String role = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    currentUsr();

  }
  void currentUsr() {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      //userEmail = currentUser.email;
      uid = currentUser.uid;
      print(currentUser.email);
    }
  }
  changeEmail() async {
    var user = FirebaseAuth.instance.currentUser;

    await user?.updateEmail(emailEditingController.text).then((_) async {
      print("Successfully changed password");
      await updateEmployeeEmail();
    }).catchError((error) {
      print("Password can't be changed" + error.toString());
      //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
    });
  }
  updateEmployeeEmail() async{
   try {
     final employeeData = await firestore
         .collection('users').doc(uid).get();

     if (employeeData['role'] == 'Employee') {
       await firestore.collection('employee_leave').doc(uid).update({
         'employeeEmail': emailEditingController.text
       });
     }


     await firestore.collection('users').doc(uid).update({
       'email': emailEditingController.text
     });

   }
     catch(e){
       print(e);
     }
   }



  @override
  void dispose() {
    Loader.hide();
    super.dispose();
  }

  Widget build(BuildContext context) {
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
            await changeEmail();
            Loader.hide();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Login_Page()),
            );
          }
        },
        child: Text(
          'Change Email',
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
                    //   'Change Email',
                    //   style: TextStyle(
                    //       fontSize: 30,
                    //       fontWeight: FontWeight.bold,
                    //       color: Colors.lightBlue),
                    // ),
                    SizedBox(
                      height: 20.0,
                    ),
                    emailField,
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

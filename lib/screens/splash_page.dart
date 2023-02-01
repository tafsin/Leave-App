import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:ttz_leave_application_demo/helper/customFunction.dart';
import 'package:ttz_leave_application_demo/screens/SA_screen.dart';
import 'package:ttz_leave_application_demo/screens/admin_screen.dart';
import 'package:ttz_leave_application_demo/screens/supervisor_screen.dart';

import 'employee_dashboard.dart';
import 'login_screen.dart';
class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
 late Widget currentPage ;
  bool isActive = false;
  final _auth = FirebaseAuth.instance;
  @override
  void initState()  {
    print('splash');
    super.initState();
    // your logic to check whether user is signed in or not
    // If user is logged in navigate to HomePage widget
    // Else navigate to SignInPage

    //FirebaseAuth.instance.userChanges().listen((User? user)

    FirebaseAuth.instance.userChanges().listen((User? user) async {
      if (user == null) {
        Loader.show(context);
        print('user null');
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Login_Page()));
       Loader.hide();
      }


      else if (user != null){
        Loader.show(context);
        await isValidUser();
        print('INIT $isActive');

        Loader.hide();
        print('splash INIT Else');
        if(isActive == true){
          await loadUser();

          await navigate();
        }


       if(isActive == false){
        await selectRoute();
       }

      }



    });




  }
   Future selectRoute () async{

        _signOut();
        Navigator.push(context, MaterialPageRoute(builder: (context)=> Login_Page()));


   }
  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Login_Page()));
  }
  isValidUser() async{
    print(' splash isValid');
    var uid ;
    var currentUser = await FirebaseAuth.instance.currentUser;
    if(currentUser != null){
      uid = currentUser.uid;
    }
    final user = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if(user!= null){
      var userData = user.data();
     if(mounted){
       setState(() {
         isActive = userData!['isActive'];
       });
     }
    }
    print('splash IS VALID USER $isActive');


  }
  String userId ='';

  //bool isActive = false;
   loadUser() async {
    print("loadUser");

    var currentUser = await FirebaseAuth.instance.currentUser;
    if (currentUser != null){
      print(currentUser.uid);
      userId = currentUser.uid;

      var roleType = await roleStream();
      print('splash login $roleType');
      //if(isActive){
        if (roleType == 'SA') {
          Loader.show(context);
          print('if');
          setState(() {
            currentPage = SA_Screen();
          });
          //Navigator.push(context, MaterialPageRoute(builder: (context)=> Admin_Page()));
          Loader.hide();

        }
        else if (roleType == 'employee') {
          Loader.show(context);
          print('else');
          setState(() {
            currentPage = Employee_Dashboard();
          });
          //Navigator.push(context, MaterialPageRoute(builder: (context)=> Employee_Dashboard()));
          Loader.hide();

        }
        else if (roleType == 'superuser') {
          Loader.show(context);
          print('else');
          setState(() {
            currentPage = Supervisor_Screen();
          });
          //Navigator.push(context, MaterialPageRoute(builder: (context)=> Supervisor_Screen()));
          Loader.hide();

        }
        else if( roleType == 'approver') {
          Loader.show(context);
          print('else');
          setState(() {
            currentPage = Admin_Page();
          });
          //Navigator.push(context, MaterialPageRoute(builder: (context)=> Supervisor_Screen()));
          Loader.hide();

        }



    }
    else{
      print('user Nai');
    }
  }
  Future<String> roleStream() async {
    var rType = '';
    bool isEmployee = false;
    bool isApprover = false;
    bool isSuperUser = false;

    try {
      final messages = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get().then((role){
        isEmployee = role['isEmployee'];
        isApprover = role['isApprover'];
        isSuperUser = role['isSuperUser'];
        //isActive = role['isSuperUser'];
        //if(isActive){
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
        //}
        // else{
        //   errorAlert(context, 'splash User Not Found');
        // }
      });


    } catch (e) {
      print(e);
    }
    return rType;
  }
  navigate() async{
    Navigator.push(context, MaterialPageRoute(builder: (context)=> currentPage));
  }


  @override
  void dispose() {
    Loader.hide();
    super.dispose();
  }
  Widget build(BuildContext context) {

    return const Center(child: CircularProgressIndicator());
  }
}
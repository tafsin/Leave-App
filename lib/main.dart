import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:ttz_leave_application_demo/screens/admin_screen.dart';
import 'package:ttz_leave_application_demo/screens/employee_dashboard.dart';
import 'package:ttz_leave_application_demo/screens/login_screen.dart';
import 'package:ttz_leave_application_demo/screens/splash_page.dart';
import 'package:ttz_leave_application_demo/screens/supervisor_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TTZLeave());
}
class TTZLeave extends StatelessWidget {
  const TTZLeave({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('aai');
    return MediaQuery(
      data: MediaQueryData(),
      child: MaterialApp(
        //theme: ThemeData.dark(),
        //theme: ThemeData(primaryColorDark: Colors.blueGrey),
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xff111949),
          ),
          //scaffoldBackgroundColor: Color(0xff0a0e21),
        ),
        // theme: ThemeData(primarySwatch: Colors.deepPurple),
        // darkTheme: ThemeData(
        //     brightness: Brightness.dark, primarySwatch: Colors.deepPurple),

        home: SplashPage(),

      ),
    );
  }
}


// class TTZLeave extends StatefulWidget {
//   const TTZLeave({Key? key}) : super(key: key);
//
//   @override
//   State<TTZLeave> createState() => _TTZLeaveState();
// }
//
// class _TTZLeaveState extends State<TTZLeave> {
//   // void initState() {
//   //   super.initState();
//   //   //var auth = FirebaseAuth.instance;
//   //   FirebaseAuth.instance.userChanges().listen((User? user) async{
//   //     if (user == null) {
//   //       print('User is currently signed out!');
//   //     }
//   //     else {
//   //
//   //       print('User is signed in!');
//   //       await loadUser();
//   //     }
//   //   });
//   // }
//   //Widget currentPage =Login_Page();
// //late final currentUser;
// //String userId ='';
//
//
//   // Future loadUser() async {
//   //   print("loadUser");
//   //
//   //    var currentUser = await FirebaseAuth.instance.currentUser;
//   //   if (currentUser != null){
//   //     print(currentUser.uid);
//   //     userId = currentUser.uid;
//   //
//   //     var roleType = await roleStream();
//   //     print('login $roleType');
//   //     if (roleType == 'Admin') {
//   //       print('if');
//   //       setState(() {
//   //         currentPage = Admin_Page();
//   //       });
//   //       Loader.hide();
//   //
//   //     }
//   //     if (roleType == 'Employee') {
//   //       print('else');
//   //       setState(() {
//   //         currentPage = Employee_Dashboard();
//   //       });
//   //       Loader.hide();
//   //
//   //     }
//   //     if (roleType == 'Supervisor') {
//   //       print('else');
//   //      setState(() {
//   //        currentPage = Supervisor_Screen();
//   //      });
//   //       Loader.hide();
//   //
//   //     }
//   //
//   //   }
//   //   else{
//   //     print('user Nai');
//   //   }
//   // }
//   // Future<String> roleStream() async {
//   //   var rType = '';
//   //   try {
//   //     final messages = await FirebaseFirestore.instance
//   //         .collection('users')
//   //         .where('uid', isEqualTo: userId)
//   //         .get();
//   //     for (var message in messages.docs) {
//   //       var role = message.data();
//   //       print(message.data());
//   //
//   //       rType = role['role'];
//   //
//   //       print('roleStream $rType');
//   //     }
//   //   } catch (e) {
//   //     print(e);
//   //   }
//   //   return rType;
//   // }
//   @override
//   // void dispose() {
//   //   Loader.hide();
//   //   super.dispose();
//   // }
//   Widget build(BuildContext context) {
//     print('aai');
//     return MediaQuery(
//       data: MediaQueryData(),
//       child: MaterialApp(
//         //theme: ThemeData.dark(),
//         //theme: ThemeData(primaryColorDark: Colors.blueGrey),
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData.light().copyWith(
//           appBarTheme: AppBarTheme(
//             backgroundColor: Color(0xff111949),
//           ),
//           //scaffoldBackgroundColor: Color(0xff0a0e21),
//         ),
//         // theme: ThemeData(primarySwatch: Colors.deepPurple),
//         // darkTheme: ThemeData(
//         //     brightness: Brightness.dark, primarySwatch: Colors.deepPurple),
//
//         home: SplashPage(),
//       ),
//     );
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ttz_leave_application_demo/screens/account_settings_screen.dart';
import 'package:ttz_leave_application_demo/screens/employee_own_leave_history.dart';
import 'package:ttz_leave_application_demo/screens/leave_application_screen.dart';
import 'package:ttz_leave_application_demo/screens/login_screen.dart';
import 'package:ttz_leave_application_demo/screens/profile_settings_screen.dart';

import '../helper/customFunction.dart';

class Employee_Dashboard extends StatefulWidget {
  const Employee_Dashboard({Key? key}) : super(key: key);

  @override
  _Employee_DashboardState createState() => _Employee_DashboardState();
}

class _Employee_DashboardState extends State<Employee_Dashboard> {
  int? leaveNum = 0;
  int? leaveTakenNum = 0;
  int? balanceLeave = 0;
  int? sickLeaveTaken = 0;
  String? employeeName = "";
  String? userEmail;
  String uid = '';
  String? imgUrl = '';
  var approverUidList = [];
  var approverNameLists = [];
  final _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<dynamic> _future;
  void initState() {
    super.initState();

    currentUsr();
    employee_leave_table_data();
    _future = getApproverList();

  }
  getApproverList() async{
    print('start $approverNameLists');
    approverNameLists = [];

    final approver = await firestore.collection('users').doc(uid).get();

    if(approver != null){
      var approverData = approver.data();
      approverUidList = approverData!['approver'];
      print(approverUidList);
    }
    for(int i =0; i<approverUidList.length;i++){
      print(approverUidList[i]);
      final apList= await firestore.collection('users').doc(approverUidList[i]).get();
      //var approverListData = apList.data();
      print(apList.data());
      var name = apList['name'];
      print(name);
      //print(approverListData!['name']);
      approverNameLists.add(name);

    }

    print(approverNameLists);




  }


  void currentUsr() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      userEmail = currentUser.email;
      uid = currentUser.uid;
      print(currentUser.email);
    }
    await firestore
        .collection('users')
        .where('uid', isEqualTo: uid)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        setState(() {
          imgUrl = (element['imageUrl']);
          print(imgUrl);
        });
      });
    });
  }


  void employee_leave_table_data() async {
    print('employee');
    try {
      final messages = await firestore
          .collection('employee_leave')
          .where('employeeEmail', isEqualTo: FirebaseAuth.instance.currentUser?.email)
          .get();
      for (var message in messages.docs) {
        var employee = message.data();
        print(message.data());
        // roleType = role['role'];
        // print(roleType);
        var year = employee['year'].toDate();
        print(year);
        var currentYear = DateTime(DateTime.now().year);
        print(currentYear);
        if (year.isAfter(currentYear)) {
          print('if');
          setState(() {
            leaveNum = employee['leaveEntitled'];
            leaveTakenNum = employee['leaveTakenNum'];
            balanceLeave = employee['balanceLeave'];
            sickLeaveTaken = employee['sickLeaveTakenNum'];
            employeeName = employee['employeeName'];
          });
        } else if (year.isAtSameMomentAs(currentYear)) {
          print('elseIF');
          setState(() {
            leaveNum = 20;
            leaveTakenNum = 0;
            balanceLeave = 20;
            sickLeaveTaken = 0;
          });
          await firestore.collection('employee_leave').doc(uid).update({
            'leaveEntitled': leaveNum,
            'balanceLeave': balanceLeave,
            'leaveTakenNum': leaveTakenNum,
            'sickLeaveTakenNum': sickLeaveTaken,
            'year': DateTime(DateTime.now().year + 1)
          });
        }

        print(employeeName);
        print("Leave Entitled $leaveNum");
        print("leave Taken $leaveTakenNum");
        print("balance leave $balanceLeave");
        print("sick leave taken $sickLeaveTaken");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (c) => Login_Page()),
            (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xff0a0e21),
      appBar: AppBar(
        //backgroundColor: Color(0xff61458e),
        title: Text(
          'TechTrioz Employee Dashboard',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        //backgroundColor: Colors.transparent,
      ),
      drawer: Drawer(
        backgroundColor: Color(0xff0a0e21),
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,

          children: [
            // const DrawerHeader(
            //   decoration: BoxDecoration(
            //     color: Colors.blue,
            //   ),
            //   child: Text('Drawer Header'),
            // ),
            SizedBox(
              height: 40.0,
            ),
            ListTile(
              title: const Text(
                'Profile Settings',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile_Settings()),
                );
              },
            ),
            ListTile(
              title: const Text(
                'Account Settings',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Account_Settings()),
                );
              },
            ),
            ListTile(
              title: const Text(
                "Leave History",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Employee_Own_History()),
                );
              },
            ),
            ListTile(
              title: const Text(
                'Logout',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                //Navigator.pop(context);
                _signOut();
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<dynamic>(
        future: _future,
        builder: (context,stream) {
          return Container(
                decoration: customDecorationBox(),
                child: ListView(
                  children: [
                    Stack(
                      children: [
                        Container(
                          //decoration: BoxDecoration(color: Colors.blueGrey),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin:
                                    EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                                child: CircleAvatar(
                                  radius: 70,
                                  backgroundColor: Colors.grey,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    radius: 65,
                                    backgroundImage:
                                        imgUrl == null ? null : NetworkImage('$imgUrl'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Container(
                        child: Center(
                          child: Text(
                            '$employeeName',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Container(
                            //width: 200,
                            height: 100,
                            child: Card(
                              color: Color(0xff61458e),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Leave Entitled in 2020',
                                    style: TextStyle(
                                        fontSize: 18,
                                        //fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        '$leaveNum',
                                        style: TextStyle(fontSize: 35),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            decoration: new BoxDecoration(

                              boxShadow: [
                                new BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 20.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            //width: 200,
                            height: 100,
                            child: Card(
                              color: Color(0xff61458e),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Annual Leave Taken',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      // fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        '$leaveTakenNum',
                                        style: TextStyle(fontSize: 35),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            decoration: new BoxDecoration(
                              boxShadow: [
                                new BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 20.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            //width: 200.0,
                            height: 100,
                            child: Card(
                              color: Color(0xff61458e),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Balance Leave',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      //fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        '$balanceLeave',
                                        style: TextStyle(fontSize: 35),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            decoration: new BoxDecoration(
                              boxShadow: [
                                new BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 20.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            //width: 200,
                            height: 100,
                            child: Card(
                              color: Color(0xff61458e),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Sick Leave taken',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      //fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        '$sickLeaveTaken',
                                        style: TextStyle(fontSize: 35),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            decoration: new BoxDecoration(
                              boxShadow: [
                                new BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 25.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: Container(
                        child: Column(

                          children: [
                            SizedBox(
                              height: 10,
                            ),

                            Center(child: Text('Approver:',style: TextStyle(color: Colors.white,fontSize: 20),)),


                                 Container(


                                  child: ListView.builder(

                                      shrinkWrap: true,
                                    itemCount: approverNameLists.length,
                                      itemBuilder: (context, index){
                                        return ListTile(

                                          title: Container(
                                              padding: EdgeInsets.all(0),
                                              child: Center(child: Text('${approverNameLists[index]}'))),
                                        );
                                      }),
                                ),


                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
        }
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(0xff111949),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Leave_Application_Page()),
          );
        },
        label: Text(
          "Apply Leave",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ttz_leave_application_demo/screens/account_settings_screen.dart';
import 'package:ttz_leave_application_demo/screens/all_emplooyee_name.dart';
import 'package:ttz_leave_application_demo/screens/leave_history.dart';
import 'package:ttz_leave_application_demo/screens/login_screen.dart';

import '../helper/customFunction.dart';

class Admin_Page extends StatefulWidget {
  const Admin_Page({Key? key}) : super(key: key);

  @override
  _Admin_PageState createState() => _Admin_PageState();
}

class _Admin_PageState extends State<Admin_Page> {
  final _auth = FirebaseAuth.instance;
  String employee = '';
  var uid = '';
  String leaveType = '';
  String leaveStartDate = '';
  String leaveEndDate = '';
  var apUid = [];
  var employeeLeave;
  var currentYear = DateTime(DateTime.now().year);
     //var currentUser = FirebaseAuth.instance.currentUser;
  //var lastDate = DateTime(DateTime.now().year, DateTime.now().month, 31);

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void initState() {
    super.initState();
    //getDataFromDatabase();
    //roleStream();
   // currentUsr();
  }
  currentUsr() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      //userEmail = currentUser.email;
      uid = currentUser.uid;
      //print(currentUser.email);
      print(uid);
      apUid.add(uid);
    }
  }

  final Future<QuerySnapshot<Map<String, dynamic>>> employeeLeaveSnapShot =
      FirebaseFirestore.instance.collection('leave_form_value').get();

  List<DataRow> createRows(employeeLeave) {
    print(employeeLeave);
    print('test1');
    List<DataRow> newRow = employeeLeave.docs
        .map<DataRow>((DocumentSnapshot docSubmissionSnapshot) {
      return DataRow2(cells: [
        DataCell(GestureDetector(
          onTap: () {
            employee = docSubmissionSnapshot.id;
            //uid = employee['uid'];
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Leave_History(employee)));

            print('docid $employee');
          },
          child: Center(
            child: Text(
              (docSubmissionSnapshot.data()
                  as Map<String, dynamic>)['employeeName'],
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )),
        DataCell(Center(
          child: Text((docSubmissionSnapshot.data()
              as Map<String, dynamic>)['leaveType']),
        )),
        DataCell(Center(
          child: Text((docSubmissionSnapshot.data()
              as Map<String, dynamic>)['startDate']),
        )),
        DataCell(Center(
          child: Text((docSubmissionSnapshot.data()
              as Map<String, dynamic>)['endDate']),
        )),
        DataCell(Center(
          child: Text((docSubmissionSnapshot.data()
              as Map<String, dynamic>)['dayToLeave']),
        )),
      ]);
    }).toList();
    return newRow;
  }

  printCurrentYear() {
    print(currentYear);
    // print(lastDate);
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (c) => Login_Page()),
            (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    //print('Admin Uid $currentUser.uid');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TechTrioz Employee Leave',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        // actions: <Widget>[
        //   IconButton(
        //       onPressed: () {
        //         _signOut();
        //         Navigator.pushReplacement(context,
        //             MaterialPageRoute(builder: (context) => Login_Page()));
        //       },
        //       icon: Icon(Icons.close))
        // ],
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
        future: currentUsr(),
        builder: (context,snapshot) {
          return Container(
            decoration: customDecorationBox(),
            child: Column(
              children: [
                // SizedBox(
                //   height: 20.0,
                // ),
                Expanded(
                  child: StreamBuilder(

                      stream: FirebaseFirestore.instance
                          .collection('leave_form_value')

                          .orderBy('startDate', descending: true)
                          .orderBy('leaveType')
                          .where('approverListArray',arrayContains:uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          print(snapshot);
                          return DataTable2(
                            columnSpacing: 4,
                            headingRowColor: MaterialStateColor.resolveWith(
                              (states) {
                                return Colors.teal.shade900;
                              },
                            ),
                            columns: [
                              DataColumn2(label: Text('Name')),
                              DataColumn2(label: Text('Leave' '\nType')),
                              DataColumn2(label: Text('Start' '\nDate')),
                              DataColumn2(label: Text('End' '\nDate')),
                              DataColumn2(label: Text('DaysTo' '\nLeave')),
                            ],
                            rows: createRows(snapshot.data).cast<DataRow>(),
                          );
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                            //Text('has no pendding leave request'),
                          );
                        }
                      }),
                ),
                SizedBox(
                  height: 20.0,
                ),

                Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey[900], // background

                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                    ), // foreground
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => All_Employee_Name()));
                    },
                    child: Text("Leave Summary",
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}

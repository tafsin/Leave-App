import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ttz_leave_application_demo/screens/account_settings_screen.dart';
import 'package:ttz_leave_application_demo/screens/all_emplooyee_name.dart';
import 'package:ttz_leave_application_demo/screens/change_user_role_name.dart';
import 'package:ttz_leave_application_demo/screens/delete_uploaded_leave_history_csv.dart';
import 'package:ttz_leave_application_demo/screens/edit_delete_employee.dart';
import 'package:ttz_leave_application_demo/screens/leave_history.dart';
import 'package:ttz_leave_application_demo/screens/leave_history_csv_upload.dart';
import 'package:ttz_leave_application_demo/screens/leave_status_csv_upload.dart';
import 'package:ttz_leave_application_demo/screens/login_screen.dart';

import '../helper/customFunction.dart';

class Supervisor_Screen extends StatefulWidget {
  const Supervisor_Screen({Key? key}) : super(key: key);

  @override
  _Supervisor_ScreenState createState() => _Supervisor_ScreenState();
}

class _Supervisor_ScreenState extends State<Supervisor_Screen> {
  final _auth = FirebaseAuth.instance;
  String employee = '';
  //var uid = '';
  String leaveType = '';
  String leaveStartDate = '';
  String leaveEndDate = '';
  var employeeLeave;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void initState() {
    super.initState();
    //getDataFromDatabase();
    //roleStream();
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
          child: Text(
            (docSubmissionSnapshot.data()
                as Map<String, dynamic>)['employeeName'],
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
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

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (c) => Login_Page()),
            (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Supervisor Screen',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                'Change Role',
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
                      builder: (context) => Change_User_Role_Name()),
                );
              },
            ),
            ListTile(
              title: const Text(
                'Manage Employee',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Edit_Or_Delete_Employee()),
                );
              },
            ),
            ListTile(
              title: const Text(
                'Upload Employee Leave Status',
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
                      builder: (context) => Leave_Status_CSV()),
                );
              },
            ),
            ListTile(
              title: const Text(
                'Upload Employee Leave History',
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
                      builder: (context) => Leave_History_CSV_Upload()),
                );
              },
            ),
            ListTile(
              title: const Text(
                'Delete Uploaded Leave History CSV',
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
                      builder: (context) => Delete_Uploaded_Leave_History_CSV()),
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
      body: Container(
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
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      print(snapshot);
                      return DataTable2(
                        columnSpacing: 5.0,
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
              height: 10,
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

            // GestureDetector(
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => All_Employee_Name()),
            //     );
            //   },
            //   child: Container(
            //     margin: EdgeInsets.only(bottom: 10),
            //     padding: EdgeInsets.fromLTRB(0, 1, 0, 100),
            //     decoration: new BoxDecoration(
            //       color: Colors.grey[900],
            //       // border: Border.all(
            //       //   color: Colors.blueGrey,
            //       // ),
            //       borderRadius: BorderRadius.all(Radius.circular(20)),
            //     ),
            //     child: Padding(
            //       padding: const EdgeInsets.only(left: 2.0),
            //       child: Center(
            //         child: Text(
            //           "Leave Summary",
            //           style: TextStyle(
            //               fontSize: 15,
            //               fontWeight: FontWeight.bold,
            //               color: Colors.white),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

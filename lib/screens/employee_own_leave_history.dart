import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../helper/customFunction.dart';

class Employee_Own_History extends StatefulWidget {
  const Employee_Own_History({Key? key}) : super(key: key);

  @override
  _Employee_Own_HistoryState createState() => _Employee_Own_HistoryState();
}

class _Employee_Own_HistoryState extends State<Employee_Own_History> {
  String uid = '';
  String? approvalStatus = 'You Do not have any pendding leave application';
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  void initState() {
    super.initState();
    currentUsr();
    updateApprovalStatus();
  }

  updateApprovalStatus() async {
    final hasUIds = await firestore
        .collection('leave_form_value')
        .where('uid', isEqualTo: uid)
        .get();
    print("hasUIds $hasUIds");
    for (var hasId in hasUIds.docs) {
      var hasPenddingId = hasId.data();
      //print('hasUIDSData $hasPenddingId');

      setState(() {
        approvalStatus = hasPenddingId['status'];
      });

      print('employee can see own status $approvalStatus');
    }
  }

  void currentUsr() {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      uid = currentUser.uid;
      print('own history $uid');
    }
  }

  List<DataRow> createPendingRows(employeeLeave) {
    print(employeeLeave);
    print('test1');
    List<DataRow> newRow = employeeLeave.docs
        .map<DataRow>((DocumentSnapshot docSubmissionSnapshot) {
      return DataRow2(cells: [
        DataCell(Text(
          (docSubmissionSnapshot.data() as Map<String, dynamic>)['leaveType'],
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        )),
        DataCell(Center(
          child: Text(
            (docSubmissionSnapshot.data()
                as Map<String, dynamic>)['startDate'],
          ),
        )),
        DataCell(Center(
          child: Text(
            (docSubmissionSnapshot.data() as Map<String, dynamic>)['endDate'],
          ),
        )),
        DataCell(Center(
          child: Text(
            (docSubmissionSnapshot.data()
                as Map<String, dynamic>)['dayToLeave'],
          ),
        )),
        DataCell(Text(
          (docSubmissionSnapshot.data() as Map<String, dynamic>)['status'],
        )),
      ]);
    }).toList();
    return newRow;
  }

  List<DataRow> createRows(employeeLeave) {
    print(employeeLeave);
    print('test1');
    List<DataRow> newRow = employeeLeave.docs
        .map<DataRow>((DocumentSnapshot docSubmissionSnapshot) {
      return DataRow2(cells: [
        DataCell(Text(
          (docSubmissionSnapshot.data() as Map<String, dynamic>)['leaveType'],
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        )),
        DataCell(Text(
          (docSubmissionSnapshot.data() as Map<String, dynamic>)['startDate'],
        )),
        DataCell(Text(
          (docSubmissionSnapshot.data() as Map<String, dynamic>)['endDate'],
        )),
        DataCell(Text(
          (docSubmissionSnapshot.data() as Map<String, dynamic>)['dayToLeave'],
        )),
        // DataCell(Text(
        //   (docSubmissionSnapshot.data() as Map<String, dynamic>)['status'],
        // )),
        (docSubmissionSnapshot.data() as Map<String, dynamic>)['status'] ==
                'Approved'
            ? DataCell(Icon(
                Icons.check,
                color: Colors.greenAccent,
              ))
            : DataCell(Icon(
                Icons.close,
                color: Colors.redAccent,
              )),
      ]);
    }).toList();
    return newRow;
  }

  final currentYear = DateTime(DateTime.now().year);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Leave History',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Container(
          decoration: customDecorationBox(),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              Container(
                child: Text(
                  "Your Pending Leaves",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('leave_form_value')
                        .where('uid', isEqualTo: uid)
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
                            DataColumn2(label: Text('Leave' '\nType')),
                            DataColumn2(
                                label: Text('Leave' '\nStart' '\nDate')),
                            DataColumn2(label: Text('Leave' '\nEnd' '\nDate')),
                            DataColumn2(label: Text('DaysTo' '\nLeave')),
                            DataColumn2(label: Text('Approval' '\nStatus')),
                          ],
                          rows:
                              createPendingRows(snapshot.data).cast<DataRow>(),
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }),
              ),
              SizedBox(
                height: 15.0,
              ),
              DottedLine(),
              SizedBox(
                height: 8.0,
              ),
              Container(
                child: Text(
                  "Your Leave History",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('employee_leave_history')
                        .where('uid', isEqualTo: uid)
                        .orderBy('leaveType')
                        .orderBy('startDate', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        print(snapshot);
                        return DataTable2(
                          columnSpacing: 5.0,
                          headingRowColor: MaterialStateColor.resolveWith(
                            (states) {
                              return Colors.grey;
                            },
                          ),
                          columns: [
                            DataColumn2(label: Text('Leave' '\nType')),
                            DataColumn2(
                                label: Text('Leave' '\nStart' '\nDate')),
                            DataColumn2(label: Text('Leave' '\nEnd' '\nDate')),
                            DataColumn2(label: Text('DaysTo' '\nLeave')),
                            DataColumn2(label: Text('Approval' '\nStatus')),
                          ],
                          rows: createRows(snapshot.data).cast<DataRow>(),
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }),
              ),
            ],
          ),
        ));
  }
}

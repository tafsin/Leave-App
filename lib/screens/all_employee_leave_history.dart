import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:ttz_leave_application_demo/helper/customFunction.dart';

class All_Employee_Leave_History extends StatefulWidget {
  //const All_Employee_Leave_History({Key? key}) : super(key: key);
  final String employeeName;

  const All_Employee_Leave_History(this.employeeName);

  @override
  _All_Employee_Leave_HistoryState createState() =>
      _All_Employee_Leave_HistoryState();
}

class _All_Employee_Leave_HistoryState
    extends State<All_Employee_Leave_History> {
  //var start = '2022-01-01';
  var currentYear = DateTime(DateTime.now().year);
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
            (docSubmissionSnapshot.data() as Map<String, dynamic>)['endDate'])),
        DataCell(Text((docSubmissionSnapshot.data()
            as Map<String, dynamic>)['dayToLeave'])),
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
        // DataCell(Text(
        //   (docSubmissionSnapshot.data() as Map<String, dynamic>)['status'],
        //   style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        // )),
      ]);
    }).toList();
    return newRow;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Employee Leave History'),
        //backgroundColor: Colors.blueGrey[900],
      ),
      //backgroundColor: Colors.grey[50],
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: customDecorationBox(),
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('employee_leave_history')
                .where('uid', isEqualTo: widget.employeeName)
                .where('leaveStartTimeStamp',
                    isGreaterThanOrEqualTo: currentYear.toString())
                .orderBy('leaveStartTimeStamp', descending: true)
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
                    DataColumn(label: Text('Leave' '\nType')),
                    DataColumn(label: Text('Leave' '\nStart' '\nDate')),
                    DataColumn(label: Text('Leave' '\nEnd' '\nDate')),
                    DataColumn(label: Text('DaysTo' '\nLeave')),
                    DataColumn(label: Text('Approval' '\nStatus')),
                  ],
                  rows: createRows(snapshot.data),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }
}

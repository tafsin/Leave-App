import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:ttz_leave_application_demo/employee_leave_history.dart';

import '../helper/customFunction.dart';

class Leave_History extends StatefulWidget {
// const Leave_History({Key? key}) : super(key: key);
  final String docId;

  const Leave_History(this.docId);

  @override
  _Leave_HistoryState createState() => _Leave_HistoryState();
}

class _Leave_HistoryState extends State<Leave_History> {
  String approvalStatus = 'Pending';
  String employeeName = '';
  String leaveType = '';
  String leaveStartDate = '';
  String leaveEndDate = '';
  String dayToLeave = '';
  String uid = '';
  String remarks = '';
  String employeeEmail = '';
  String approverUid = '';
  var leaveStartTimeStamp;
  var leaveEndTimeStamp;
  var leaveEntitled;
  var balanceLeave;
  var leaveTakenNum;
  var sickLeaveTakenNum;
  var approveCount;
  var approverlistLength;
  final TextEditingController emailSub = TextEditingController();
  final TextEditingController emailBody = TextEditingController();
  var currentYear = DateTime(DateTime.now().year);

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  void initState() {
    super.initState();
    //getStatus();
    currentUsr();
    getapproverMapList();
    getFormValuesAfterClick();
    employeeLeaveStatusSum();
  }

  void currentUsr() async {
    var currentUser = await FirebaseAuth.instance.currentUser;
    if (currentUser != null) {

      approverUid = currentUser.uid;
      print('approver uid $approverUid');
      //print(currentUser.email);
    }
  }

  getFormValuesAfterClick() async {
    print(widget.docId);
    final formvalues =
        await firestore.collection('leave_form_value').doc(widget.docId).get();
    print(formvalues.data());
    late DateTime lvSt;
    late DateTime lvEnd;
    lvSt = formvalues['leaveStart'].toDate();
    lvEnd = formvalues['leaveEnd'].toDate();
    setState(() {
      leaveType = formvalues['leaveType'];
      leaveStartDate = formvalues['startDate'];
      leaveEndDate = formvalues['endDate'];
      dayToLeave = formvalues['dayToLeave'];
      employeeName = formvalues['employeeName'];
      uid = formvalues['uid'];
      remarks = formvalues['remarks'];
      employeeEmail = formvalues['userEmail'];
      leaveStartTimeStamp = lvSt.toString();
      leaveEndTimeStamp = lvEnd.toString();
      approveCount = formvalues['approveCount'];
      approverlistLength = formvalues['approverList'].length;
    });
    //var leaveTimes = leaveStartTimeStamp.toDate();
    // print('leaveSSSS $leaveStartTimeStamp');
    // print('leaveEndddd $leaveEndTimeStamp');
    print('approverListLength $approverlistLength');
  }

  deleteDoc(docId) async {
    await firestore.collection('leave_form_value').doc(docId).delete();
  }
  employeeLeaveStatusSum() async {
    final formVal =
        await firestore.collection('leave_form_value').doc(widget.docId).get();
    var userId = formVal['uid'];
    print("UserId $userId");
    final employeeLeaveDetails =
        await firestore.collection('employee_leave').doc(userId).get();

    setState(() {
      leaveEntitled = employeeLeaveDetails['leaveEntitled'];
      balanceLeave = employeeLeaveDetails['balanceLeave'];
      leaveTakenNum = employeeLeaveDetails['leaveTakenNum'];
      sickLeaveTakenNum = employeeLeaveDetails['sickLeaveTakenNum'];
    });

    print(leaveEntitled);
    print(leaveTakenNum);
    print(sickLeaveTakenNum);
    print(balanceLeave);
  }
  Map<String,dynamic> approverMapList ={};

  getapproverMapList()async{
    print('map');
    final em = await firestore.collection('leave_form_value').doc(widget.docId).get();
    approverMapList.addAll(em['approverList']);
    print('map map $approverMapList');
  }

updateApproverListStatus(bool isApprove) async{
  //var fPath = FieldPath(["approver", "$approverUid"]);
  print('updateApproverListStatus');
  if(isApprove == true){
    await firestore.collection('leave_form_value').doc(widget.docId).update({"approverList.$approverUid" : true});
    approveCount++;
  }
  if(isApprove == false){
    approveCount = -1;
  }
  await firestore.collection('leave_form_value').doc(widget.docId).update({'approveCount': approveCount});
  await checkApproveCount();
}
checkApproveCount()async{
  final formvalues =
  await firestore.collection('leave_form_value').doc(widget.docId).get();
  var count = formvalues['approveCount'];
  if(count == approverlistLength) {
    print("LEAVE APPROVED");
    setState(() {
      approvalStatus = "Approved";
    });


   await addLeaveHistory(
        leaveType,
        leaveStartDate,
        leaveEndDate,
        dayToLeave,
        uid,
        employeeName,
        approvalStatus,
        leaveStartTimeStamp,
        leaveEndTimeStamp);
    await updateEmployeeLeave();
    await employeeLeaveStatusSum();
    sendApprovedEmail();
    //employeeLeaveStatusSum();

    deleteDoc(widget.docId);

  }
  else if( count > 0 && count <approverlistLength){
    print('count is less than approvallistCount');
    print(count);
    print(approveCount);
    String apCount = count.toString();
    String status = '';

    setState(() {
      status = 'approved by ' + apCount;
    });
    print(approvalStatus);
    await firestore.collection('leave_form_value').doc(widget.docId).update({'status': status});

  }
  else if(count == -1){
    print('Leave NOT APPROVED');
    setState(() {
      approvalStatus = "Not Approved";
    });
    addLeaveHistory(
        leaveType,
        leaveStartDate,
        leaveEndDate,
        dayToLeave,
        uid,
        employeeName,
        approvalStatus,
        leaveStartTimeStamp,
        leaveEndTimeStamp);
    showAlertDialog(context);
    deleteDoc(widget.docId);

  }

}

addLeaveHistory(
      String leaveType,
      String leaveStartDate,
      String leaveEndDate,
      String dayToLeave,
      String uid,
      String employeeName,
      String status,
      var leaveStartTimeStamp,
      var leaveEndTimeStamp) async {
    print('leaveStartTime $leaveEndTimeStamp');
    print('leaveEndTime $leaveEndTimeStamp');
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    //User? user = _auth.currentUser;
    Employee_Leave_Histroy leaveHistoryValue = Employee_Leave_Histroy();
    leaveHistoryValue.leaveType = leaveType;
    leaveHistoryValue.startDate = leaveStartDate;
    leaveHistoryValue.endDate = leaveEndDate;
    leaveHistoryValue.daysToLeave = dayToLeave;
    leaveHistoryValue.uid = uid;

    leaveHistoryValue.employeeName = employeeName;

    leaveHistoryValue.status = status;
    leaveHistoryValue.leaveStartTimeStamp = leaveStartTimeStamp;
    leaveHistoryValue.leaveEndTimeStamp = leaveEndTimeStamp;

    await firebaseFirestore
        .collection("employee_leave_history")
        .doc(widget.docId)
        .set(leaveHistoryValue.toMap());
  }

  updateEmployeeLeave() async {
    int daysToLeave = int.parse(dayToLeave);
    var updatedbalanceLeave;
    if (leaveType == 'Annual') {
      if (balanceLeave == 0) {
        updatedbalanceLeave = balanceLeave;
      } else {
        updatedbalanceLeave = balanceLeave - daysToLeave;
      }
    } else {
      updatedbalanceLeave = balanceLeave;
    }

    var updatedLeaveTakenNum = 0;
    var updatedSickLeaveTakenNum = 0;
    print(leaveType);
    if (leaveType == 'Sick') {
      updatedSickLeaveTakenNum = sickLeaveTakenNum + daysToLeave;
    } else {
      updatedSickLeaveTakenNum = sickLeaveTakenNum;
    }
    if (leaveType == 'Annual') {
      updatedLeaveTakenNum = leaveTakenNum + daysToLeave;
    } else {
      updatedLeaveTakenNum = leaveTakenNum;
    }

    print('updatedBL $updatedbalanceLeave');
    print('updatedLeaveTkn $updatedLeaveTakenNum');
    print('updatedsickleavetk $updatedSickLeaveTakenNum');
    await firestore.collection('employee_leave').doc(uid).update({
      'balanceLeave': updatedbalanceLeave,
      'leaveTakenNum': updatedLeaveTakenNum,
      'sickLeaveTakenNum': updatedSickLeaveTakenNum
    });
  }

  List<DataRow> createRows(employeeLeave) {
    print(employeeLeave);
    print('test1');
    List<DataRow> newRow = employeeLeave.docs
        .map<DataRow>((DocumentSnapshot docSubmissionSnapshot) {
      return DataRow2(cells: [
        DataCell(Center(
          child: Text((docSubmissionSnapshot.data()
              as Map<String, dynamic>)['leaveType']),
        )),
        DataCell(
          Center(
            child: Text((docSubmissionSnapshot.data()
                as Map<String, dynamic>)['startDate']),
          ),
        ),
        DataCell(Center(
          child: Text((docSubmissionSnapshot.data()
              as Map<String, dynamic>)['endDate']),
        )),
        DataCell(Center(
          child: Text((docSubmissionSnapshot.data()
              as Map<String, dynamic>)['dayToLeave']),
        )),
        // DataCell(Center(
        //   child: Text(
        //       (docSubmissionSnapshot.data() as Map<String, dynamic>)['status']),
        // )),
        (docSubmissionSnapshot.data() as Map<String, dynamic>)['status'] ==
                'Approved'
            ? DataCell(Icon(
                Icons.check,
                color: Colors.green.shade900,
              ))
            : DataCell(Icon(
                Icons.close,
                color: Colors.red.shade900,
              )),
      ]);
    }).toList();
    //print(newRow.length);
    return newRow;
  }

  sendApprovedEmail() async {
    String username = 'ttzztasnim@gmail.com';
    String password = 'TTZ12345';

    final smtpServer = gmail(username, password);
    // Use the SmtpServer class to configure an SMTP server:
    // final smtpServer = SmtpServer('smtp.domain.com');
    // See the named arguments of SmtpServer for further configuration
    // options.

    // Create our message.
    final message = Message()
      ..from = Address(username, 'ttzzz tasnim')
      ..recipients.add(employeeEmail)
      ..subject = 'Leave Approved'
      ..text = 'This is the plain text.\nThis is line 2 of the text part.'
      ..html = "<p>Your Leave is Approved</p>";

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  showAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = ElevatedButton(
      child: Text("Send"),
      onPressed: () {
        sendEmail();

        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Send an email to $employeeName"),
      content: Column(
        children: [
          // TextField(
          //   autofocus: true,
          //   controller: emailSub,
          //   decoration: InputDecoration(hintText: 'subject'),
          // ),
          TextField(
            autofocus: true,
            controller: emailBody,
            decoration: InputDecoration(hintText: 'Reason'),
          ),
        ],
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  sendEmail() async {
    String username = 'ttzztasnim@gmail.com';
    String password = 'TTZ12345';

    String emailbody = emailBody.text;

    final smtpServer = gmail(username, password);
    // Use the SmtpServer class to configure an SMTP server:
    // final smtpServer = SmtpServer('smtp.domain.com');
    // See the named arguments of SmtpServer for further configuration
    // options.

    // Create our message.
    final message = Message()
      ..from = Address(username, 'ttzzz tasnim')
      ..recipients.add(employeeEmail)
      ..subject = 'Leave Not Approved'
      ..text = 'This is the plain text.\nThis is line 2 of the text part.'
      ..html = "<p>$emailbody</p>";

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
  // showCurrentApprovalStatus() async {
  //   // if(approveCount == 0){
  //   //   return Text('No one approved Yet');
  //   // }
  //   final formvaluesApCount =
  //   await firestore.collection('leave_form_value').doc(widget.docId).get();
  //
  //   var apCount = formvaluesApCount['aproveCount'];
  //   print(apCount);
  //
  //   if( apCount> 0 && apCount< approverlistLength){
  //     return Text('Yet to be Approved');
  //
  //   }
  //
  //
  //
  // }


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
            Text(
              employeeName,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    child: Card(
                      color: Colors.blue,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Annual LeaveTaken',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
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
                    ),
                    decoration: new BoxDecoration(
                      boxShadow: [
                        new BoxShadow(
                          color: Colors.black,
                          blurRadius: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 100,
                    child: Card(
                      color: Colors.blue,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sick Leave Taken',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  '$sickLeaveTakenNum',
                                  style: TextStyle(fontSize: 35),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    decoration: new BoxDecoration(
                      boxShadow: [
                        new BoxShadow(
                          color: Colors.black,
                          blurRadius: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 100,
                    child: Card(
                      color: Colors.blue,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Balance Leave',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                            Expanded(
                                child: Center(
                                    child: Text(
                              '$balanceLeave',
                              style: TextStyle(fontSize: 35),
                            ))),
                          ],
                        ),
                      ),
                    ),
                    decoration: new BoxDecoration(
                      boxShadow: [
                        new BoxShadow(
                          color: Colors.black,
                          blurRadius: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(left: 5.0),
                child: Text(
                  'Remarks:',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(width: 2.0, color: Colors.black),
                          left: BorderSide(width: 2.0, color: Colors.black),
                          right: BorderSide(width: 2.0, color: Colors.black),
                          bottom: BorderSide(width: 2.0, color: Colors.black),
                        ),
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Text(
                      remarks,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Text(
                    "Approval Status:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,decorationColor: Colors.blue,),
                  ),
                ),
                Container(
                  child: Text(
                    '  $approvalStatus',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                 style: ElevatedButton.styleFrom(
                  primary: Colors.green, // background

                   shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(25)),
                 ), // foreground
                  onPressed: () async {
                    // setState(() {
                    //   print(approveCount);
                    //   approvalStatus = "Approved";
                    // });
                    //postStatus(approvalStatus);
                   await updateApproverListStatus(true);

                  },
                  child: Text('Approve',style: TextStyle(color: Colors.white),),
                ),
                SizedBox(
                  width: 20.0,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // background

                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)), // foreground
                  ),
                  onPressed: () async {
                    // setState(() {
                    //
                    //   approvalStatus = "Not Approved";
                    // });
                    // postStatus(approvalStatus);
                    await updateApproverListStatus(false);

                    // addLeaveHistory(
                    //     leaveType,
                    //     leaveStartDate,
                    //     leaveEndDate,
                    //     dayToLeave,
                    //     uid,
                    //     employeeName,
                    //     approvalStatus,
                    //     leaveStartTimeStamp,
                    //     leaveEndTimeStamp);
                    // showAlertDialog(context);
                    // deleteDoc(widget.docId);
                  },
                  child: Text('Not Approve',style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            // Container(
            //   child: showCurrentApprovalStatus(),
            // ),
            //approverMapList
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: approverMapList.entries.map((e) {
                  print(' jygyj ${approverMapList}');
                  if(e.key ==approverUid){
                    return Container();
                  }
                  else {
                    return FutureBuilder(
                      future: FirebaseFirestore.instance.collection('users').doc(e.key).get(),
                      builder: (context, snapshot) {
                        if(snapshot.hasData){
                          print(e.key);

                          var DocData = snapshot.data as DocumentSnapshot;
                          //print(DocData['name'] as dynamic);
                          print("${DocData.data()} efef");
                          //return Container();
                          //Map d = (DocData.data()) as Map<dynamic,dynamic>;
                          //print('sss ${d['name'] as dynamic}');
                          var txt;
                          if(e.value == false){
                            txt = 'decision is pending';
                            print(txt);
                          }
                          else{
                            txt = 'approved the leave';
                            print(txt);
                          }
                           return Container(child: Text('${((DocData.data()??{}) as Map<dynamic,dynamic>)['name']} ${txt}   '),);
                          //return Container(child: Text('${d['name']} ${e.value}'),);
                        }
                        else{
                          return Center(child: CircularProgressIndicator());
                        }
                      }
                    );
                  }

                }).toList(),
              ),
            ),

            SizedBox(
              height: 25.0,
            ),
            Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('employee_leave_history')
                      .where('uid', isEqualTo: uid)
                      //.where('startDate', isGreaterThanOrEqualTo: '01-01-2022')
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
                            return Colors.teal;
                          },
                        ),
                        columns: [
                          DataColumn2(label: Text('Leave' '\nType')),
                          DataColumn2(label: Text('Leave' '\nStart' '\nDate')),
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
      ),
    );
  }
}

Future getName(String key) async {
  var approverName = await FirebaseFirestore.instance.collection('users').doc(key).get();
  return approverName;
}

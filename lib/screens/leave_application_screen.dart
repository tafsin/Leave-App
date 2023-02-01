import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:ttz_leave_application_demo/screens/account_settings_screen.dart';
import 'package:ttz_leave_application_demo/screens/employee_own_leave_history.dart';
import 'package:ttz_leave_application_demo/screens/profile_settings_screen.dart';

import '../form_values.dart';
import '../helper/customFunction.dart';
import 'login_screen.dart';

class Leave_Application_Page extends StatefulWidget {
  const Leave_Application_Page({Key? key}) : super(key: key);

  @override
  _Leave_Application_PageState createState() => _Leave_Application_PageState();
}

class _Leave_Application_PageState extends State<Leave_Application_Page> {
  final TextEditingController daysController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  CollectionReference ref =
      FirebaseFirestore.instance.collection('leave_form_value');
  int? leaveNum = 0;
  int? leaveTakenNum = 0;
  int? balanceLeave = 0;
  int? sickLeaveTaken = 0;
  String? employeeName = "";
  String? userEmail;
  String uid = '';
  String? leaveType;
  bool daysValidator = false;

  var approverList=[];
  final _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users =
      FirebaseFirestore.instance.collection('employee_leave');
  // String dropdownValue = 'Annual';

  final items = ['Annual', 'Sick', 'Other'];
  String? value;
  String? status = 'Pending';
  TextEditingController dateinput1 = TextEditingController();
  TextEditingController dateinput2 = TextEditingController();
  late DateTime leaveStartDate;
  late DateTime leaveEndDate;
  //List<Map<String, bool>> approverLists = [];
  Map<String,bool> approverLists ={};
  @override
  void initState() {
    dateinput1.text = "";
    dateinput2.text = "";
    super.initState();
    //getAdminsEmail();

    currentUsr();
    getEmployeeName();

    //updateStatus();
    //roleStream();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Loader.hide();
  }

  // checkLeaveType() {}

  void currentUsr() {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      userEmail = currentUser.email;
      uid = currentUser.uid;
      print(currentUser.email);
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Login_Page()));
  }
  getApproverList() async{

    final approver = await firestore.collection('users').doc(uid).get();

     if(approver != null){
       var approverData = approver.data();
        approverList = approverData!['approver'];
       print(approverList);
     }

    print(approverList.length);
     for(int i =0; i<approverList.length;i++){
       approverLists.addAll({approverList[i]:false});
     }
     print(approverLists);


  }


getEmployeeName()async{
      final employeeData = await firestore
          .collection('employee_leave')
          .where('uid', isEqualTo: uid)
          .get();
      for(var employee in employeeData.docs){
        var employeeInfo = employee.data();
        setState(() {
          employeeName=employeeInfo['employeeName'];
        });
      }
}
  Future<void> postFromVal(
    String? leaveType,
    String startDate,
    String endDate,
    String totalLeaveDays,
    String? userEmail,
    String? employeeName,
    String? remarks,
    DateTime? leaveStart,
    DateTime? leaveEnd,
    String? status,
      Map approverslist,
      List approverListArray,
  ) async {
    print(leaveType);
    print(startDate);
    print(endDate);
    print(userEmail);
    print(employeeName);
    print(remarks);
    print(leaveStart);
    print(leaveEnd);
    print('fsdf');
    print(status);
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    FormValue formValue = FormValue();
    formValue.leaveType = leaveType;
    formValue.startDate = startDate;
    formValue.endDate = endDate;
    formValue.daysToLeave = totalLeaveDays;
    formValue.uid = user!.uid;
    formValue.userEmail = userEmail;
    formValue.employeeName = employeeName;
    formValue.remarks = remarks;
    formValue.leaveStartDate = leaveStart;
    formValue.leaveEndDate = leaveEnd;
    formValue.status = status;
    formValue.approverLists = approverslist;
    formValue.approverListArray = approverListArray;

    await firebaseFirestore
        .collection("leave_form_value")
        .doc()
        .set(formValue.toMap());
  }

  // updateStatus() async {
  //   final messages = await firestore
  //       .collection('leave_form_value')
  //       .where('uid', isEqualTo: uid)
  //       .get();
  //   for (var message in messages.docs) {
  //     var formvalues = message.data();
  //     print(message.data());
  //
  //     setState(() {
  //       status = formvalues['status'];
  //     });
  //
  //     print('getStatus $status');
  //   }
  // }

  showAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = ElevatedButton(
      child: Text("OK"),
      onPressed: () async {
        setState(() {
          value = null;
        });
        dateinput1.clear();
        dateinput2.clear();
        daysController.clear();
        remarksController.clear();
        Navigator.of(context).pop();



        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Employee_Own_History()),
        );

      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Sent for Approval"),
      content: Text("Your Leave Application Submitted Successfully."),
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


   List adminEmails = [];
  getAdminsEmail() async {
    print('emails $approverList');
    approverList.forEach((element) async {
      print('uid of ap $element');
      await firestore
          .collection('users')
          .where('uid', isEqualTo: element)
          .get()
          .then((value) {
        value.docs.forEach((e) {
          adminEmails.add(e['email']);
        });
      });
    });


    print('Emails of admin $adminEmails');
  }

  sendEmailToAdmins() async {
    String username = 'ttzztasnim@gmail.com';
    String password = 'TTZ12345';

    final smtpServer = gmail(username, password);
    // Use the SmtpServer class to configure an SMTP server:
    // final smtpServer = SmtpServer('smtp.domain.com');
    // See the named arguments of SmtpServer for further configuration
    // options.

    print(adminEmails);
    // Create our message.
    final message = Message()
      ..from = Address(username, 'ttzzz tasnim')
      ..recipients.addAll(adminEmails)
      ..subject = 'Leave Application'
      ..text = 'This is the plain text.\nThis is line 2 of the text part.'
      ..html = "<p>One Leave Application Submitted by $employeeName</p>";

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

  // bool checkDaysToApplyValidity() {
  //   var startDate = dateinput1.text;
  //   var endDate = dateinput2.text;
  //   var numStartDate = int.parse(startDate);
  //   var numEndDate = int.parse(endDate);
  //   var dateDiff = numEndDate - numStartDate;
  //   var days = daysController.text;
  //   var numDays = int.parse(days);
  //   if (numDays == 1 && dateDiff == 0) {
  //     daysValidator = true;
  //   } else if (numDays == dateDiff) {
  //     daysValidator = true;
  //   } else {
  //     daysValidator = false;
  //   }
  //   return daysValidator;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.teal,
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'TechTrioz Employee Leave Form',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        // actions: <Widget>[
        //   IconButton(
        //       onPressed: () {
        //         // await _auth.signOut();
        //         //Navigator.pop(context);
        //         //await FirebaseAuth.instance().signOut();
        //         _signOut();
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
      body: Container(
        decoration: customDecorationBox(),
        child: ListView(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 50,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    height: 80,
                    //margin: EdgeInsets.all(8.0),
                    margin: EdgeInsets.fromLTRB(5, 4, 5, 1),
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      //errorStyle: TextStyle(fontSize: 0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: value,
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
                      hint: Text(
                        'Select a Leave Type',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        errorStyle: TextStyle(fontSize: 0),
                      ),
                      items: items.map(buildMenuItem).toList(),
                      onChanged: (value) => {
                        setState(() {
                          this.value = value;
                          leaveType = value;
                          //checkleaveType();
                        }),
                      },
                      validator: (value) => value == null ? '' : null,
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Container(
                            height: 70,
                            // height: 110,
                            child: TextFormField(
                              controller: dateinput1,
                              decoration: InputDecoration(
                                labelText: "Leave Start Date",
                                labelStyle: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                                errorStyle: TextStyle(fontSize: 0),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(width: 2.0),
                                    borderRadius: BorderRadius.circular(10)),
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(10.0)),
                              ),
                              readOnly: true,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(), //DateTime.now() - not to allow to choose before today.
                                    lastDate: DateTime(2101));
                                if (pickedDate != null) {
                                  print(pickedDate);
                                  String formattedDate =
                                      DateFormat('dd-MM-yy')
                                          .format(pickedDate);
                                  print(formattedDate);
                                  setState(() {
                                    dateinput1.text = formattedDate;
                                    leaveStartDate = pickedDate;
                                  });
                                } else {
                                  setState(() {
                                    dateinput1.text = 'select a date please!';
                                  });
                                  print('date is not selected');
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a date';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Container(
                            height: 70,
                            //height: 110,
                            child: TextFormField(
                              controller: dateinput2,
                              decoration: InputDecoration(
                                labelText: "Leave End Date",
                                labelStyle: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900),
                                errorStyle: TextStyle(fontSize: 0),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(width: 2.0),
                                    borderRadius: BorderRadius.circular(10)),
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(10.0)),
                              ),
                              readOnly: true,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),//DateTime.now() - not to allow to choose before today.
                                    lastDate: DateTime(2101));
                                if (pickedDate != null) {
                                  print(pickedDate);
                                  String formattedDate =
                                      DateFormat('dd-MM-yy')
                                          .format(pickedDate);
                                  print(formattedDate);
                                  setState(() {
                                    dateinput2.text = formattedDate;
                                    leaveEndDate = pickedDate;
                                  });
                                } else {
                                  setState(() {
                                    dateinput2.text = 'select a date please!';
                                  });
                                  print('date is not selected');
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a date';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 2.0,
                  ),
                  Container(
                    height: 70,
                    //height: 110,
                    //margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: TextFormField(
                      controller: daysController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                        hintText: 'Days to Apply',
                        errorText:
                            daysValidator ? 'Value Can\'t Be Empty' : null,
                        errorStyle: TextStyle(fontSize: 0),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                            borderRadius: BorderRadius.circular(10)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some number';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: 2.0,
                  ),
                  Container(
                    height: 70,
                    //height: 110,
                    //margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: TextFormField(
                      controller: remarksController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                        hintText: 'Remarks',
                        errorStyle: TextStyle(fontSize: 0),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0),
                            borderRadius: BorderRadius.circular(10)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.blue,
                        child: MaterialButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              print('sending for approval');
                              Loader.show(context);
                              await getApproverList();
                              await getAdminsEmail();
                             await postFromVal(
                                  leaveType,
                                  dateinput1.text,
                                  dateinput2.text,
                                  daysController.text,
                                  userEmail,
                                  employeeName,
                                  remarksController.text,
                                  leaveStartDate,
                                  leaveEndDate,
                                  status,
                                approverLists,
                                  approverList
                                  );
                              //postApproverList();
                              Loader.hide();
                              showAlertDialog(context);
                            }
                          },
                          child: const Text(
                            'Send for Approval',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.grey[900],
                        child: MaterialButton(
                          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                          onPressed: () {
                            print('clicked');
                            setState(() {
                              value = null;
                            });
                            dateinput1.clear();
                            dateinput2.clear();
                            daysController.clear();
                            remarksController.clear();
                          },
                          child: Text(
                            'Clear',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 2,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      );
}

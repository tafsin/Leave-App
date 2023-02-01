import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ttz_leave_application_demo/screens/all_employee_leave_history.dart';

import '../helper/customFunction.dart';

class All_Employee_Name extends StatefulWidget {
  const All_Employee_Name({Key? key}) : super(key: key);

  @override
  _All_Employee_NameState createState() => _All_Employee_NameState();
}

class _All_Employee_NameState extends State<All_Employee_Name> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getName();
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<DataRow> createRows(employeeLeave) {
    print(employeeLeave);
    //print('test1');
    List<DataRow> newRow = employeeLeave.docs
        .map<DataRow>((DocumentSnapshot docSubmissionSnapshot) {
      return DataRow(cells: [
        DataCell(Text(
            (docSubmissionSnapshot.data() as Map<String, dynamic>)['email'])),
      ]);
    }).toList();

    return newRow;
  }

  List<String> allEmployeeName = [];

  getName() async {
    final allEmployee = await firestore.collection('users').get();
    for (var employee in allEmployee.docs) {
      print(employee.data());
      var employeeName = employee.data()['name'];
      var employeeRole = employee.data()['role'];
      print(employeeName);
      print(employeeRole);
      if (employeeRole == 'Employee') {
        allEmployeeName.add(employeeName);
      }
    }
    print(allEmployeeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('All Employee Name')),
        //backgroundColor: Colors.blueGrey[900],
      ),
      // body: StreamBuilder(
      //     stream: FirebaseFirestore.instance.collection('users').snapshots(),
      //     builder: (context, snapshot) {
      //       if (snapshot.hasData) {
      //         print(snapshot);
      //         return DataTable(
      //           columns: [
      //             DataColumn(label: Text('name')),
      //           ],
      //           rows: createRows(snapshot.data).cast<DataRow>(),
      //         );
      //       } else {
      //         return Center(
      //           child: CircularProgressIndicator(),
      //         );
      //       }
      //     }),
      body: Container(
        decoration: customDecorationBox(),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('employee_leave')
               .orderBy('employeeName')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            print('test 1');
            return ListView(
              children: snapshot.data!.docs.map((document) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () {
                      var employeeName = document['uid'];
                      print(employeeName);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                All_Employee_Leave_History(employeeName)),
                      );
                    },
                    child: Container(
                      height: 150,
                      width: 100,
                      decoration: BoxDecoration(
                          color: Colors.cyan[900],
                          border: Border.all(
                            color: Colors.green,
                            width: 4.0,
                          ),
                          borderRadius: BorderRadius.circular(5.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(document['employeeName'],
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            RichText(
                                text: TextSpan(children: [
                              const TextSpan(
                                  text: 'Annual Leave Taken: ',
                                  style: TextStyle(fontSize: 20.0)),
                              TextSpan(
                                  text: document['leaveTakenNum'].toString(),
                                  style: const TextStyle(
                                      fontSize: 18.0, color: Colors.black87))
                            ])),
                            SizedBox(
                              height: 4.0,
                            ),
                            RichText(
                                text: TextSpan(children: [
                              const TextSpan(
                                  text: 'Sick Leave Taken: ',
                                  style: TextStyle(fontSize: 20.0)),
                              TextSpan(
                                  text:
                                      document['sickLeaveTakenNum'].toString(),
                                  style: const TextStyle(
                                      fontSize: 18.0, color: Colors.black87))
                            ])),
                            SizedBox(
                              height: 4.0,
                            ),
                            RichText(
                                text: TextSpan(children: [
                              const TextSpan(
                                  text: 'Balance Leave: ',
                                  style: TextStyle(fontSize: 20.0)),
                              TextSpan(
                                  text: document['balanceLeave'].toString(),
                                  style: const TextStyle(
                                      fontSize: 18.0, color: Colors.black87))
                            ])),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),

      //new ListView.builder(
      //     itemCount: allEmployeeName.length,
      //     itemBuilder: (BuildContext ctxt, int index) {
      //       return Padding(
      //         padding: const EdgeInsets.all(12.0),
      //         child: GestureDetector(
      //           onTap: () {
      //             print('tapped');
      //             // Navigator.push(
      //             //     context,
      //             //     MaterialPageRoute(
      //             //         builder: (context) =>
      //             //             All_Employee_Leave_History()));
      //             // Navigator.push(
      //             //   context,
      //             //   MaterialPageRoute(
      //             //       builder: (context) => All_Employee_Leave_History()),
      //             // );
      //           },
      //           child: Container(
      //             height: 50,
      //             color: Colors.blue,
      //             child: Center(
      //               child: new Text(
      //                 allEmployeeName[index],
      //                 style: TextStyle(
      //                     fontSize: 20,
      //                     fontWeight: FontWeight.bold,
      //                     color: Colors.white),
      //               ),
      //             ),
      //           ),
      //         ),
      //       );
      //     })
    );
  }
}

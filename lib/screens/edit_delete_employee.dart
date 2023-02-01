import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ttz_leave_application_demo/screens/add_approver_to_employee.dart';
import 'package:ttz_leave_application_demo/screens/add_employee_approver.dart';
import 'package:ttz_leave_application_demo/screens/edit_employee_leave.dart';

import '../helper/customFunction.dart';
class Edit_Or_Delete_Employee extends StatefulWidget {
  const Edit_Or_Delete_Employee({Key? key}) : super(key: key);

  @override
  State<Edit_Or_Delete_Employee> createState() => _Edit_Or_Delete_EmployeeState();
}

class _Edit_Or_Delete_EmployeeState extends State<Edit_Or_Delete_Employee> {
deleteUser ( uid ) async{
  await FirebaseFirestore.instance.collection('users').doc(uid).update({
    'isActive': false
  });
  await FirebaseFirestore.instance.collection('employee_leave').doc(uid).update({
    'isActive': false
  });
}
addApprover (uid) async{
  var approverArray = ['approver1', 'approver2'];
  await FirebaseFirestore.instance.collection('users').doc(uid).update({
    'approver': approverArray
  });
  // firebase.database().ref('attendees').once('value', function(snapshot) {
  // console.log(snapshot.val());
  // ["Bill Gates", "Larry Page", "James Tamplin"]

}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('All User List')),
      ),
      body: Container(
        //width: MediaQuery.of(context).size.width,
        decoration: customDecorationBox(),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('isEmployee', isEqualTo: true)
              .where('isActive', isEqualTo: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }


            return ListView(

              children: snapshot.data!.docs.map((document) {
                return Container(
                  margin: EdgeInsets.fromLTRB(8, 10, 8, 5),
                  height: 180,
                  width: 10,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      border: Border.all(
                        color: Colors.blue.shade300,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 5.0,
                        ),
                        Row(
                          children: [
                            // Text('Username: ',
                            //     style: TextStyle(
                            //         fontSize: 20,
                            //         fontWeight: FontWeight.bold,
                            //         color: Colors.white)),
                            Icon(Icons.person),
                            SizedBox(
                              width: 4,
                            ),
                            Text(document['name'],
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff0a0e21))),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            // Text('Useremail: ',
                            //     style: TextStyle(
                            //         fontSize: 20,
                            //         fontWeight: FontWeight.bold,
                            //         color: Colors.white)),
                            Icon(Icons.mail),
                            SizedBox(
                              width: 4,
                            ),
                            Text(document['email'],
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff0a0e21))),
                          ],
                        ),

                        Expanded(
                          child: SizedBox(
                            height: 30,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Material(
                              elevation: 5,
                              borderRadius: BorderRadius.circular(30),
                              color: Color(0xff111949),

                              child: MaterialButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> Edit_Employee_Leave(document['uid'])));

                                },
                                //child: roleDecider(document['role'].toString()),
                                child: Text('Edit Leave',style: TextStyle(color: Colors.white),),
                              ),
                            ),
                            Material(
                              elevation: 5,
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.red[700],
                              child: MaterialButton(
                                onPressed: () {
                                  //addApprover(document['uid']);
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> Add_Approver_TO_Employee(document['uid'])));


                                },
                                //child: roleDecider(document['role'].toString()),
                                child: Text('Add Approver',style: TextStyle(color: Colors.white),),
                              ),
                            ),
                            Material(
                              elevation: 5,
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.red[700],
                              child: MaterialButton(
                                onPressed: () {
                                  deleteUser(document['uid']);


                                },
                                //child: roleDecider(document['role'].toString()),
                                child: Text('Delete Employee',style: TextStyle(color: Colors.white),),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

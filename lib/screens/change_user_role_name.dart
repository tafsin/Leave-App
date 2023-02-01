import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

import '../helper/customFunction.dart';

class Change_User_Role_Name extends StatefulWidget {
  const Change_User_Role_Name({Key? key}) : super(key: key);

  @override
  _Change_User_Role_NameState createState() => _Change_User_Role_NameState();
}

class _Change_User_Role_NameState extends State<Change_User_Role_Name> {

  roleDecider(String role) {
    if (role == 'Admin') {
      return Text(
        'Change to Employee',
      );
    } else if (role == "Employee") {
      return Text("Change to Approver");
    }
  }

  updateToApprover(uid,role) async {
    print(role);
   if(role == true) {
     await FirebaseFirestore.instance.collection('users').doc(uid).update({
       'isApprover': false
     });
   }
     else if(role == false){
     await FirebaseFirestore.instance.collection('users').doc(uid).update({
       'isApprover': true
     });
   }

    print('updated');
  }
  updateToSuperUser(uid,role) async {
    print(role);
    if(role == false){
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'isSuperUser': true
      });
    }
    else if(role == true){
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'isSuperUser': false
      });
    }
    print('updated');
  }

  updateEmployee_Leave_Table(uid) async {

      await FirebaseFirestore.instance
          .collection('employee_leave')
          .doc(uid)
          .delete();

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
              .where('role', isNotEqualTo: 'Supervisor')
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
                      color: Colors.brown[100],
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
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            // Text("User's Current Role: ",
                            //     style: TextStyle(
                            //         fontSize: 20,
                            //         fontWeight: FontWeight.bold,
                            //         color: Colors.white)),
                            Icon(Icons.badge),
                            SizedBox(
                              width: 4,
                            ),
                            Text(document['role'],
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff0a0e21))),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Material(
                              elevation: 5,
                              borderRadius: BorderRadius.circular(30),
                              color: document['isApprover'] == true ? Colors.green[700] : Colors.red[700],
                              child: MaterialButton(
                                onPressed: () {
                                  Loader.show(context);
                                  //bool buttonPress = false;
                                  // if (document['role'] == "Admin") {
                                  //   updateUserRole('Employee', document['uid']);
                                  // } else if (document['role'] == "Employee") {
                                  //   updateUserRole('Admin', document['uid']);
                                  //   updateEmployee_Leave_Table(
                                  //       'Admin', document['uid']);
                                  // }
                                  updateToApprover(document['uid'],document['isApprover']);
                                  updateEmployee_Leave_Table(document['uid']);
                                  Loader.hide();
                                  // String employeeName = document['name'];
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             Change_User_Role(employeeName)));
                                },
                                //child: roleDecider(document['role'].toString()),
                                child: Text('Make Approver'),
                              ),
                            ),
                            Material(
                              elevation: 5,
                              borderRadius: BorderRadius.circular(30),
                              color: document['isSuperUser'] == true ? Colors.green[700] : Colors.red[700],
                              child: MaterialButton(
                                onPressed: () {
                                  Loader.show(context);
                                  //bool buttonPress = false;
                                  // if (document['role'] == "Admin") {
                                  //   updateUserRole('Employee', document['uid']);
                                  // } else if (document['role'] == "Employee") {
                                  //   updateUserRole('Admin', document['uid']);
                                  //   updateEmployee_Leave_Table(
                                  //       'Admin', document['uid']);
                                  // }
                                  updateToSuperUser(document['uid'],document['isSuperUser']);
                                    updateEmployee_Leave_Table(document['uid']);
                                  Loader.hide();
                                  // String employeeName = document['name'];
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             Change_User_Role(employeeName)));
                                },
                                //child: roleDecider(document['role'].toString()),
                                child: Text('Make SuperUser'),
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

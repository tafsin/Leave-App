import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helper/customFunction.dart';
class Edit_Employee_Leave extends StatefulWidget {
  //const Edit_Employee_Leave({Key? key}) : super(key: key);
  final String uid;

  const Edit_Employee_Leave(this.uid);

  @override
  State<Edit_Employee_Leave> createState() => _Edit_Employee_LeaveState();
}

class _Edit_Employee_LeaveState extends State<Edit_Employee_Leave> {
  TextEditingController leaveEntitiled = TextEditingController();
  TextEditingController balanceLeave = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  updateEmployeeLeave()async{
    var entiledLeave = int.parse(leaveEntitiled.text);
    var bLeave = int.parse(balanceLeave.text);
    await FirebaseFirestore.instance.collection('employee_leave').doc(widget.uid).update({
       'leaveEntitled': entiledLeave,
        'balanceLeave': bLeave,
    });
  }
  showAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = ElevatedButton(
      child: Text("OK"),
      onPressed: () async {
        leaveEntitiled.clear();
        balanceLeave.clear();
        Navigator.pop(context);


      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Leave Status Updated"),
      content: Text(""),
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
  @override
  Widget build(BuildContext context) {
    print(widget.uid);
    return Scaffold(
      body: Container(
        decoration: customDecorationBox(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                ),

                Container(
                  height: 70,
                  //height: 110,
                  //margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: TextFormField(
                    controller: leaveEntitiled,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                      hintText: 'Edit Entilted Leave',
                      hintStyle: TextStyle(color: Colors.white),
                      errorStyle: TextStyle(fontSize: 0),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0),
                          borderRadius: BorderRadius.circular(10)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some value';
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  height: 70,
                  //height: 110,
                  //margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: TextFormField(
                    controller: balanceLeave,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                      hintText: 'Edit balance Leave',
                      hintStyle: TextStyle(color: Colors.white),
                      errorStyle: TextStyle(fontSize: 0),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0),
                          borderRadius: BorderRadius.circular(10)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some value';
                      }
                      return null;
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blueGrey,

                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                      ),

                      onPressed: (){
                          if (_formKey.currentState!.validate()) {
                            updateEmployeeLeave();
                            showAlertDialog(context);
                          };
                      },
                        child: Text('Save',style: TextStyle(color: Colors.white),),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

import '../helper/customFunction.dart';
class Delete_Uploaded_Leave_History_CSV extends StatefulWidget {
  const Delete_Uploaded_Leave_History_CSV({Key? key}) : super(key: key);

  @override
  State<Delete_Uploaded_Leave_History_CSV> createState() => _Delete_Uploaded_Leave_History_CSVState();
}

class _Delete_Uploaded_Leave_History_CSVState extends State<Delete_Uploaded_Leave_History_CSV> {
  TextEditingController uploadedFileNumber = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Delete_Leave_History_Csv() async{
    await FirebaseFirestore.instance.collection('employee_leave_history').where('uploadFileNumber',isEqualTo: uploadedFileNumber.text).get().then((value){
      value.docs.forEach((element) async {
        print(element.id);
        await FirebaseFirestore.instance.collection('employee_leave_history').doc(element.id).delete();
      });
    });
  }
  showAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = ElevatedButton(
      child: Text("OK"),
      onPressed: () async {
        Navigator.pop(context);
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Leave History Deleted Sucessfully"),
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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Loader.hide();
  }
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Delete Uploaded CSV File"),
      ),
      body: Container(
        decoration: customDecorationBox(),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Container(
                height: 70,
                //height: 110,
                //margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: TextFormField(
                  controller: uploadedFileNumber,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                    hintText: 'Enter Uploaded File Number',
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

                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey,
                    ), // background


                    onPressed: ()async{
                      if (_formKey.currentState!.validate()) {
                        Loader.show(context);
                       await Delete_Leave_History_Csv();
                       Loader.hide();
                       showAlertDialog(context);
      
                      }
                      
                    },
                    child: Text('Delete',style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

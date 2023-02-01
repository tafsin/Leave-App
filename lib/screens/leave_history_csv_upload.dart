import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

import '../helper/customFunction.dart';
import 'package:intl/intl.dart';
class Leave_History_CSV_Upload extends StatefulWidget {
  const Leave_History_CSV_Upload({Key? key}) : super(key: key);

  @override
  State<Leave_History_CSV_Upload> createState() => _Leave_History_CSV_UploadState();
}

class _Leave_History_CSV_UploadState extends State<Leave_History_CSV_Upload> {
  TextEditingController uploadFileNumber = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String historyFileName ='example.csv';
  late List<dynamic> employeeData;
  List<PlatformFile>? _paths;
  String? _extension="csv";
  FileType _pickingType = FileType.custom;
  bool alreadyUploaded = false;
  @override
  void pickHistoryFile() async{

    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        historyFileName = file.name;
      });

      print(file.name);
      print(file.bytes);
      print(file.size);
      print(file.extension);
      print(file.path);
      openFile(file.path);
    } else {
      // User canceled the picker
    }
  }
  openFile(filepath) async
  {
    File f = new File(filepath);
    print("CSV to List");
    final input = f.openRead();
    final fields = await input.transform(utf8.decoder).transform(new CsvToListConverter()).toList();
    print(fields);
    setState(() {
      employeeData=fields;
    });
    print('list $employeeData');
  }
  uploadLeaveHistoryData() async {



    print('uploadLeave history');
    List temp = employeeData;
    temp.removeAt(0);
    // userId = [];
    temp.forEach((element) async {
      print("file number $uploadFileNumber");
      print('gagadfe');
      print(element[0]);
      print(element[3]);
      print(element[4]);
      print(element[3].runtimeType);
      print(element[4].runtimeType);

      //leaveStart = DateTime.parse(element[3]);
      //print(leaveStart);
      //leaveEnd = element[4].toDate();

      DateTime leaveStart = new DateFormat("yyyy-MM-dd").parse(element[3]);
      DateTime leaveEnd = new DateFormat("yyyy-MM-dd").parse(element[4]);
      print('tempDate $leaveStart');
      print('tempDate $leaveEnd');
      String startformattedDate =
      DateFormat('dd-MM-yy')
          .format(leaveStart);
      String endformattedDate =
      DateFormat('dd-MM-yy')
          .format(leaveEnd);
      print('formatted Date $startformattedDate');
      print('formatted Date $endformattedDate');




      var leaveStartTimeStamp = leaveStart.toString();
      var leaveEndTimeStamp = leaveEnd.toString();
      print(leaveStartTimeStamp);
      print(leaveEndTimeStamp);
      await FirebaseFirestore.instance.collection('users').where('email',isEqualTo: element[0]).get().then((value) async {
        var userId = value.docs.first.id;

        await FirebaseFirestore.instance.collection('employee_leave_history').doc().set({
          'employeeName':element[1],
          'leaveType':element[2],
          'startDate': startformattedDate,
          'endDate': endformattedDate,
          'dayToLeave': element[5].toString(),
          'status': element[6],
          'leaveStartTimeStamp': leaveStartTimeStamp,
          'leaveEndTimeStamp': leaveEndTimeStamp,
          'uid': userId,
          'uploadFileNumber': uploadFileNumber.text

        },SetOptions(merge: false));
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
      title: Text("Leave History Uploaded Sucessfully"),
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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Loader.hide();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Exiting Leave History'),
      ),
      body: Container(
        decoration: customDecorationBox(),
        child: Column(
          children: [
            Form(
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
                      controller: uploadFileNumber,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                        hintText: 'Enter Uploading File Number',
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
                        primary:Colors.grey,
                      ),// background


                        onPressed: (){
                          pickHistoryFile();
                        },
                        child: Text('select leave history csv file',style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  ),

                  Text('$historyFileName',
                    style: TextStyle(color: Colors.blue),
                  ),
                  Container(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green, // background

                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                      onPressed: () async{
                        if (_formKey.currentState!.validate()) {
                          Loader.show(context);
                          await uploadLeaveHistoryData();
                          Loader.hide();
                          //print(userId);
                          showAlertDialog(context);
                        }

                      },
                      child: Text('upload leave history',style: TextStyle(color:Colors.white),),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

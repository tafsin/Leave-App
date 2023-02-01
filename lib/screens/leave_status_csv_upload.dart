import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:date_format/date_format.dart';

import '../helper/customFunction.dart';
import 'package:intl/intl.dart';

class Leave_Status_CSV extends StatefulWidget {
  const Leave_Status_CSV({Key? key}) : super(key: key);

  @override
  State<Leave_Status_CSV> createState() => _Leave_Status_CSVState();
}

class _Leave_Status_CSVState extends State<Leave_Status_CSV> {
  late List<dynamic> employeeData;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String fileName = 'example.csv';
  String historyFileName ='example.csv';

  List<PlatformFile>? _paths;
  String? _extension="csv";
  FileType _pickingType = FileType.custom;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    employeeData  = List<List<dynamic>>.empty(growable: true);
  }
  // void _openFileExplorer() async {
  //
  //   try {
  //
  //     _paths = (await FilePicker.platform.pickFiles(
  //       type: _pickingType,
  //       allowMultiple: false,
  //       allowedExtensions: (_extension?.isNotEmpty ?? false)
  //           ? _extension?.replaceAll(' ', '').split(',')
  //           : null,
  //     ))
  //         ?.files;
  //   } on PlatformException catch (e) {
  //     print("Unsupported operation" + e.toString());
  //   } catch (ex) {
  //     print(ex);
  //   }
  //   if (!mounted) return;
  //   setState(() {
  //     openFile(_paths![0].path);
  //     print(_paths);
  //     print("File path ${_paths![0]}");
  //     print(_paths!.first.extension);
  //
  //   });
  // }
 void pickFile() async{

   FilePickerResult? result = await FilePicker.platform.pickFiles();

   if (result != null) {
     PlatformFile file = result.files.first;
    setState(() {
      fileName = file.name;
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

  List emailList=[];
  List userId = [];
  uploadData() async {
    List docId=[];

    WriteBatch batch = FirebaseFirestore.instance.batch();

    emailList = [];
    int i=0;
    for(int i = 1; i< employeeData.length;i++){
      emailList.add(employeeData[i][0]);
    }
    List temp = employeeData;
    temp.removeAt(0);
    userId = [];
    temp.forEach((element) async {
      print('gagadfe');
      print(element[0]);
      await FirebaseFirestore.instance.collection('users').where('email',isEqualTo: element[0]).get().then((value) async {
        userId.add(value.docs.first.id);
        await FirebaseFirestore.instance.collection('employee_leave').doc(value.docs.first.id).set({
          'leaveEntitled':element[2],
          'leaveTakenNum':element[3],
          'sickLeaveTakenNum': element[4],
          'balanceLeave': element[2]-element[3]

        },SetOptions(merge: true));
      });
    });


  }
  uploadLeaveHistoryData() async {
    //List docId=[];

    //WriteBatch batch = FirebaseFirestore.instance.batch();

    // emailList = [];
    // int i=0;
    // for(int i = 1; i< employeeData.length;i++){
    //   emailList.add(employeeData[i][0]);
    // }
    print('uploadLeave history');
    List temp = employeeData;
    temp.removeAt(0);
   // userId = [];
    temp.forEach((element) async {
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
          'uid': userId

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
      title: Text("Leave Status Uploaded Sucessfully"),
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
    print(employeeData);

    // print(employeeData[1][1]);
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Current Leave Status'),

      ),
      body: Container(
        decoration: customDecorationBox(),
        child: Column(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Container(

                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey
                      ),// background


                      onPressed: (){
                        pickFile();
                        },
                      child: Text('select leave status csv file',style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ),

                Text('$fileName',
                style: TextStyle(color: Colors.blue),
                ),
                Container(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green, // background

                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                    ),
                    onPressed: (){
                      uploadData();
                      print(userId);
                      showAlertDialog(context);
                      },
                    child: Text('upload leave status',style: TextStyle(color: Colors.white),),
                  ),
                ),

              ],
            ),

          ],
        ),
      )
    );
  }
}

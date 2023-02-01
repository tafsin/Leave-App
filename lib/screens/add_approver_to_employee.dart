import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

import '../helper/customFunction.dart';

class Add_Approver_TO_Employee extends StatefulWidget {
  //const Add_Approver_TO_Employee({Key? key}) : super(key: key);
  final String uid;

  const Add_Approver_TO_Employee(this.uid);


  @override
  State<Add_Approver_TO_Employee> createState() => _Add_Approver_TO_EmployeeState();
}

class _Add_Approver_TO_EmployeeState extends State<Add_Approver_TO_Employee> {
  var approverUidList = [];
  var tempList = [];
  var approverNameLists = [];
  late Future<dynamic> future;
  void initState()  {
    super.initState();
   // currentApprover = getApproverList();
    //future = getApproverList();
  }


  getApproverUid(approver) async {
    approverUidList = [];
    print('get approver $approver');
    await Future.forEach(approver, (element) async{
      await FirebaseFirestore.instance.collection('users')
          .where('name', isEqualTo: element)
          .get().then((value){
        approverUidList.add(value.docs.first.id);
        print('uid list inside approver for each then value $approverUidList');
      });
    });
    // approver.forEach((element) async {
    //   await FirebaseFirestore.instance.collection('users')
    //       .where('name', isEqualTo: element)
    //       .get().then((value)async{
    //          approverUidList.add(value.docs.first.id);
    //          print('uid list inside approver for each then value $approverUidList');
    //   });
    //
    //   print('uid list inside approver for each  $approverUidList');
    // }
    // );
    print('uid list outside approver for each');



  }
  addApprover (uid) async{
    print(uid);
    print("selected items $approverUidList");
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'approver': approverUidList
    });

    print('Approvers added $approverUidList');
  }
  List<String> _selectedItems = [];
  var approversNameList=[];
  List<String> approverNameListMuti = [];
  populateMultiSelect() async{
    approversNameList=[];
    approverNameListMuti=[];

    final approvers =  await FirebaseFirestore.instance.collection('users').where('isApprover',isEqualTo: true).get();

    for(var ap in approvers.docs){
      var approversData = ap.data();
      print(approversData['name']);
      approversNameList.add(approversData['name']);
      tempList.add(approversData['uid']);

    }

    for (int i =0; i<approversNameList.length;i++) {
      approverNameListMuti.add( approversNameList[i]);
    }

  }
  void _showMultiSelect() async {
    // a list of selectable items
    // these items can be hard-coded or dynamically fetched from a database/API
    // final List<String> _items = [
    //   'Flutter',
    //   'Node.js',
    //   'React Native',
    //   'Java',
    //   'Docker',
    //   'MySQL'
    // ];
     await populateMultiSelect();
    print('name list $approverNameListMuti');
    final _items = approverNameListMuti;

    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(items: _items);
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        _selectedItems = results;
      });
    }
  }
  getApproverList() async{
    approverNameLists=[];

    final approver = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();

    if(approver != null){
      var approverData = approver.data();
      approverUidList = approverData!['approver'];
      print(approverUidList);
    }
    for(int i =0; i<approverUidList.length;i++){
      final apList= await FirebaseFirestore.instance.collection('users').doc(approverUidList[i]).get();
      var approverListData = apList.data();
      var name = approverListData!['name'];
      //print(approverListData!['name']);
      approverNameLists.add(name);

    }
    print('approvers Name $approverNameLists');




  }
  deleteCurrentApporver() async{
    _selectedItems =[];
    await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({'approver': FieldValue.delete()});
    approverNameLists = [];
    setState(() {

    });
    print('deleted');
  }
  deleteParticularApprover(name)async{
    print(name);
    var apUid;
    final approvers = await FirebaseFirestore.instance.collection('users').where('name',isEqualTo: name).get();
    // for(var approver in approvers.docs){
    //   var approverData = approver.data();
    //   apUid = approverData['uid'];
    //
    // }
    var apuid = approvers.docs.first.id;
    print("uid $apUid");
    print("docid $apuid");

    await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({'approver': FieldValue.arrayRemove([apuid])});
   print('d');

    setState(() {

    });
  }
  saveNewList() async {
    await getApproverUid(_selectedItems);
    setState(() {
      print('refresh');
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Loader.hide();
  }
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Leave Approver for Employee'),
      ),
      body: FutureBuilder<dynamic>(
        future: getApproverList(),
        builder: (context, snapshot) {
          return Container(
            decoration: customDecorationBox(),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Card(
                  color: Colors.white24,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            child: Text('Current Approvers',style: TextStyle(fontSize: 20,),),
                          ),
                          IconButton(onPressed: (){

                            deleteCurrentApporver();

                            }, icon: Icon(Icons.delete))
                        ],
                      ),
                      Container(


                        child: ListView.builder(

                            shrinkWrap: true,
                            itemCount: approverNameLists.length,
                            itemBuilder: (context, index){
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 20.0),
                                child: Card(


                                  child: ListTile(

                                    title: Container(

                                        child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text('${approverNameLists[index]}'))),
                                    trailing: IconButton(onPressed: ()async{
                                      Loader.show(context);
                                      await deleteParticularApprover(approverNameLists[index]);
                                      Loader.hide();}, icon: Icon(Icons.cancel)),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),

                ElevatedButton(
                  child: const Text('Select Approver'),
                  onPressed: _showMultiSelect,
                ),
                // Wrap(
                //   children: _selectedItems
                //       .map((e) => Chip(
                //     label: Text(e),
                //   ))
                //       .toList(),
                // ),
                ListView.builder(

                    shrinkWrap: true,
                    itemCount: _selectedItems.length,
                    itemBuilder: (context, index){
                      return ListTile(

                          title: Container(
                              padding: EdgeInsets.all(0),
                              child:Chip(
                                label: Text(_selectedItems[index]),
                              ))
                      );
                    }),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blueGrey,

                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                    onPressed: ()async{
                      Loader.show(context);
                      await getApproverUid(_selectedItems);
                      await addApprover(widget.uid);
                      setState(() {

                      });
                      Loader.hide();


                    },
                    child: Text('save',style: TextStyle(color: Colors.white),)),
                // IconButton(onPressed: ()async{await getApproverUid(_selectedItems);
                //   setState(() {
                //
                //   });}, icon: Icon(Icons.save))

              ],
            ),

          );
        }
      ),
    );
  }
}


class MultiSelect extends StatefulWidget {
  final List<String> items;
  const MultiSelect({Key? key, required this.items}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  // this variable holds the selected items
  final List<String> _selectedItems = [];

// This function is triggered when a checkbox is checked or unchecked
  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
      } else {
        _selectedItems.remove(itemValue);
      }
    });
  }

  // this function is called when the Cancel button is pressed
  void _cancel() {
    Navigator.pop(context);
  }

// this function is called when the Submit button is tapped
  void _submit() {
    Navigator.pop(context, _selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Approver'),
      content: Container(
        height: 200,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: ListBody(
            children: widget.items
                .map((item) => CheckboxListTile(
              value: _selectedItems.contains(item),
              title: Text(item),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (isChecked) => _itemChange(item, isChecked!),
            ))
                .toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: _cancel,
        ),
        ElevatedButton(
          child: const Text('Submit'),
          onPressed: _submit,
        ),
      ],
    );
  }
}

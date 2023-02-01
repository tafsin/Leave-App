import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../helper/customFunction.dart';

class Add_Employee_Approver extends StatefulWidget {
  //const Add_Employee_Approver({Key? key}) : super(key: key);
  final String uid;

  const Add_Employee_Approver(this.uid);

  @override
  State<Add_Employee_Approver> createState() => _Add_Employee_ApproverState();
}

class _Add_Employee_ApproverState extends State<Add_Employee_Approver> {
  TextEditingController approver = TextEditingController();

  var approverUidList = [];
  var tempList = [];

  getApproverUid(approver) async {
    //approverUidList = [];
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

    await addApprover(widget.uid);

  }
  addApprover (uid) async{
    print(uid);
    print("selected items $approverUidList");
    var approverArray = ['approver1', 'approver2'];
   // approverUidList.forEach((element) async {
     // print('element $element');
      //var apUidlist = [];
     // apUidlist.add(element);
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'approver': approverUidList
      });
   // });
    print('Approvers added $approverUidList');

  }
  List<MultiSelectDialogItem<int>> approverNameListMuti = List<MultiSelectDialogItem<int>>.empty(growable: true);
  var approversNameList=[];
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

    for (int i =1; i<approversNameList.length-1;i++) {
      approverNameListMuti.add(MultiSelectDialogItem(i, approversNameList[i]));
    }

  }
  void _showMultiSelect(BuildContext context) async {
   //  approversNameList=[];
   //  approverNameListMuti=[];
   //
   // final approvers =  await FirebaseFirestore.instance.collection('users').where('isApprover',isEqualTo: true).get();
   //
   // for(var ap in approvers.docs){
   //   var approversData = ap.data();
   //   print(approversData['name']);
   //   approversNameList.add(approversData['name']);
   //   tempList.add(approversData['uid']);
   //
   // }
   //
   // for (int i =1; i<approversNameList.length-1;i++) {
   //   approverNameListMuti.add(MultiSelectDialogItem(i, approversNameList[i]));
   // }

     // final items = <MultiSelectDialogItem<int>>[
     //   MultiSelectDialogItem(),
     //   // MultiSelectDialogItem(2, 'Cat'),
     //   // MultiSelectDialogItem(3, 'Mouse'),
     // ];
    await populateMultiSelect();
    print(approversNameList);
    List<MultiSelectDialogItem<int>> items = [];
    for(int i = 0; i<approverNameListMuti.length;i++){
      items.add(approverNameListMuti[i]);
    }



 print("Items $approversNameList");
    final selectedValues = await showDialog<Set<int>>(
      context: context,
      builder: (BuildContext context) {
        print('build $items');
        return MultiSelectDialog(
        items: items,
        initialSelectedValues: [1].toSet(),
        );

      },
    );


    print(selectedValues);
   await getSelectedValue(selectedValues);
  }
  List<String> _selectedItems = [];
   getSelectedValue(Set ?selection) async{
     _selectedItems = [];
    if(selection != null){
      for(int x in selection.toList()){
        print(approversNameList[x]);
         setState(() {
           _selectedItems.add(approversNameList[x]);
         });
      }
    }
    print(_selectedItems);

  }


  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Leave Approver for Employee'),
      ),
      body: Container(
        decoration: customDecorationBox(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            ElevatedButton(onPressed: (){
              _showMultiSelect(context);
            }, child: Text('DropDown')),
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


                    await getApproverUid(_selectedItems);
                   //await addApprover(widget.uid);
                    //print(approverList);
                    approver.clear();


                },
                child: Text('save',style: TextStyle(color: Colors.white),))

          ],
        ),

      ),
    );
  }
}
class MultiSelectDialogItem<V> {
  const MultiSelectDialogItem(this.value, this.label);

  final V value;
  final String label;
}

class MultiSelectDialog<V> extends StatefulWidget {
  MultiSelectDialog({ Key? key, required this.items, required this.initialSelectedValues}) : super(key: key);

  final List<MultiSelectDialogItem<V>> items;
  final Set<V> initialSelectedValues;

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState<V>();
}

class _MultiSelectDialogState<V> extends State<MultiSelectDialog<V>> {
  final _selectedValues = Set<V>();

  void initState() {
    super.initState();
    if (widget.initialSelectedValues != null) {
      _selectedValues.addAll(widget.initialSelectedValues);
    }
  }

  void _onItemCheckedChange(V itemValue, bool checked) {
    setState(() {
      if (checked) {
        _selectedValues.add(itemValue);
      } else {
        _selectedValues.remove(itemValue);
      }
    });
  }

  void _onCancelTap() {
    Navigator.pop(context);
  }

  void _onSubmitTap() {
    Navigator.pop(context, _selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select emp'),
      contentPadding: EdgeInsets.only(top: 12.0),
      content: Container(
        height: 200,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              ListTileTheme(
                contentPadding: EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
                child: ListBody(
                  children: widget.items.map(_buildItem).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: Text('CANCEL'),
          onPressed: _onCancelTap,
        ),
        ElevatedButton(
          child: Text('OK'),
          onPressed: _onSubmitTap,
        )
      ],
    );
  }

  Widget _buildItem(MultiSelectDialogItem<V> item) {
    final checked = _selectedValues.contains(item.value);
    return CheckboxListTile(
      value: checked,
      title: Text(item.label),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) => _onItemCheckedChange(item.value, checked!),
    );
  }
 }



import 'package:flutter/material.dart';
import 'package:ttz_leave_application_demo/screens/admin_screen.dart';
import 'package:ttz_leave_application_demo/screens/supervisor_screen.dart';

import '../helper/customFunction.dart';
class SA_Screen extends StatefulWidget {
  const SA_Screen({Key? key}) : super(key: key);

  @override
  State<SA_Screen> createState() => _SA_ScreenState();
}

class _SA_ScreenState extends State<SA_Screen> {
  int currentIndex = 0;
  onItemTapped(int index){
    setState(() {
      currentIndex = index;
    });
    if(index == 0){
      Navigator.push(context, MaterialPageRoute(builder: (context)=> Supervisor_Screen()));
    }
    if(index == 1){
      Navigator.push(context, MaterialPageRoute(builder: (context)=> Admin_Page()));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'TechTrioz Solution',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: customDecorationBox(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.batch_prediction_outlined),
            label: 'Continue As SuperUser',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Continue As Approver',
            backgroundColor: Colors.green,
          ),

        ],
        currentIndex: currentIndex,
        //selectedItemColor: Colors.red[800],
        onTap: onItemTapped,
      ),
    );
  }
}

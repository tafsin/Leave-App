import 'package:flutter/material.dart';
import 'package:ttz_leave_application_demo/screens/email_change_screen.dart';
import 'package:ttz_leave_application_demo/screens/password_change_screen.dart';

import '../helper/customFunction.dart';

class Account_Settings extends StatefulWidget {
  const Account_Settings({Key? key}) : super(key: key);

  @override
  _Account_SettingsState createState() => _Account_SettingsState();
}

class _Account_SettingsState extends State<Account_Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settngs'),
      ),
      body: Container(
        //height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: customDecorationBox(),
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Email_Change()),
                );
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xff111949),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Change Email',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Password_Change()),
                );
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xff111949),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Change Password',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

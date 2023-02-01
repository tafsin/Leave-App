import 'package:flutter/material.dart';

errorAlert(context, String e) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(e),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Ok',
                  style: TextStyle(color: Colors.white),
                ))
          ],
        );
      });
}

customDecorationBox() {
  return BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Colors.red.shade200, Colors.blue.shade900]));
}

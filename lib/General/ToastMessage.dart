import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<bool?> toastMessage(String message) {
  return Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.blueAccent,
      fontSize: 16.0,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT);
}

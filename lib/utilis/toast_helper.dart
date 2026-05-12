// lib/utilis/toast_helper.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showCustomToast(BuildContext context, String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    backgroundColor: const Color(0xFFFF0505),
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

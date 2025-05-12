import 'package:flutter/material.dart';

class Snackbarwidget {
  Color textColor;
  String content;
  Color backgroundColor;
  Snackbarwidget(
      {required this.textColor,
      required this.content,
      required this.backgroundColor});
  showSnackBar() {
    SnackBar(
      content: Text(
        content,
        style: TextStyle(color: textColor),
      ),
      backgroundColor: backgroundColor,
    );
  }
}

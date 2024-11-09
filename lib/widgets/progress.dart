import 'package:flutter/material.dart';

Container circularProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 10.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/icon/logo-small.png',
          height: 100, // adjust size as needed
          width: 100,
        ),
        SizedBox(height: 20), // spacing between logo and spinner
        CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation(Colors.green),
        ),
      ],
    ),
  );
}
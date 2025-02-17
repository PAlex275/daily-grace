import 'package:flutter/material.dart';

Widget logo({
  bool isSmall = false,
  double height = 400,
  double width = 400,
}) {
  if (isSmall == true) {
    return SizedBox(
      height: height,
      width: width,
      child: Image(
        fit: BoxFit.fill,
        image: AssetImage('assets/images/icon.png'),
      ),
    );
  } else {
    return SizedBox(
      width: width,
      height: height,
      child: Image(
        image: AssetImage(
          'assets/images/daily_grace.png',
        ),
      ),
    );
  }
}

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
      child: const Image(
        fit: BoxFit.fill,
        image: AssetImage('assets/images/dailygracesmall.png'),
      ),
    );
  } else {
    return SizedBox(
      width: width,
      height: height,
      child: const Image(
        image: AssetImage('assets/images/dailygrace.png'),
      ),
    );
  }
}

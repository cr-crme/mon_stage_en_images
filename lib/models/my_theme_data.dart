import 'package:flutter/material.dart';

ThemeData myThemeData() {
  const primaryColor = Colors.lightGreen;

  return ThemeData(
      primarySwatch: primaryColor,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: primaryColor,
      ));
}

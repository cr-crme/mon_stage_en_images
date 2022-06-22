import 'package:flutter/material.dart';

ThemeData myThemeData() {
  const primaryColor = Colors.amber;

  return ThemeData(
      primarySwatch: primaryColor,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: primaryColor,
      ));
}

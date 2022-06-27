import 'package:flutter/material.dart';

ThemeData teacherTheme() {
  const primaryColor = Colors.amber;
  const fontFamily = 'Urbanist';
  final colorSwatch = ColorScheme.fromSwatch(
    primarySwatch: primaryColor,
    accentColor: Colors.amber[700],
  );

  const textTheme = TextTheme(
    titleLarge: TextStyle(color: Colors.black),
  );
  final appBarTheme = AppBarTheme(
    titleTextStyle: TextStyle(
        fontSize: 20, color: colorSwatch.onPrimary, fontFamily: fontFamily),
  );

  return ThemeData(
    primarySwatch: primaryColor,
    colorScheme: colorSwatch,
    fontFamily: fontFamily,
    textTheme: textTheme,
    appBarTheme: appBarTheme,
  );
}

ThemeData studentTheme() {
  const primaryColor = Colors.green;
  const fontFamily = 'Urbanist';
  final colorSwatch = ColorScheme.fromSwatch(
    primarySwatch: primaryColor,
    accentColor: Colors.green[700],
  );

  const textTheme = TextTheme(
    titleLarge: TextStyle(color: Colors.black),
  );
  final appBarTheme = AppBarTheme(
    titleTextStyle: TextStyle(
        fontSize: 20, color: colorSwatch.onPrimary, fontFamily: fontFamily),
  );

  return ThemeData(
    primarySwatch: primaryColor,
    colorScheme: colorSwatch,
    fontFamily: fontFamily,
    textTheme: textTheme,
    appBarTheme: appBarTheme,
  );
}

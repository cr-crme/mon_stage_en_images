import 'package:flutter/material.dart';

ThemeData teacherTheme() {
  const primaryColor = Colors.amber;
  const fontFamily = 'Urbanist';
  final colorSwatch = ColorScheme.fromSwatch(
    primarySwatch: primaryColor,
    accentColor: Colors.amber[700],
    backgroundColor: Colors.grey[50],
  );

  const textTheme = TextTheme(
    titleLarge: TextStyle(color: Colors.black),
  );
  final appBarTheme = AppBarTheme(
    titleTextStyle: TextStyle(
        fontSize: 20, color: colorSwatch.onPrimary, fontFamily: fontFamily),
    color: primaryColor,
    iconTheme: const IconThemeData(color: Colors.black),
  );
  final dialogTheme = DialogTheme(
      backgroundColor: Colors.white, surfaceTintColor: Colors.grey[200]);

  const inputDecorationTheme = InputDecorationTheme(
    focusedBorder:
        OutlineInputBorder(borderSide: BorderSide(color: Colors.black54)),
    enabledBorder:
        OutlineInputBorder(borderSide: BorderSide(color: Colors.black54)),
    disabledBorder:
        OutlineInputBorder(borderSide: BorderSide(color: Colors.black54)),
    errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
    labelStyle: TextStyle(color: Colors.black),
  );

  final cardTheme =
      CardTheme(color: Colors.grey[100], surfaceTintColor: Colors.white);

  final elevatedButton = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold)),
  );

  final outlinedButton = OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.white,
    side: const BorderSide(color: primaryColor),
    textStyle: const TextStyle(fontWeight: FontWeight.bold),
  ));

  final switchTheme = SwitchThemeData(
    thumbColor: MaterialStateProperty.all(Colors.white),
    trackColor: MaterialStateProperty.resolveWith((status) {
      return status.contains(MaterialState.selected)
          ? primaryColor
          : Colors.grey;
    }),
    trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
  );

  final dividerTheme = DividerThemeData(color: Colors.grey[200], thickness: 1);
  final checkboxTheme = CheckboxThemeData(
    checkColor: MaterialStateProperty.all(Colors.white),
    side: BorderSide(color: Colors.grey[700]!),
  );

  return ThemeData(
    primarySwatch: primaryColor,
    colorScheme: colorSwatch,
    fontFamily: fontFamily,
    textTheme: textTheme,
    appBarTheme: appBarTheme,
    dialogTheme: dialogTheme,
    inputDecorationTheme: inputDecorationTheme,
    cardTheme: cardTheme,
    elevatedButtonTheme: elevatedButton,
    outlinedButtonTheme: outlinedButton,
    switchTheme: switchTheme,
    dividerTheme: dividerTheme,
    checkboxTheme: checkboxTheme,
  );
}

ThemeData studentTheme() {
  const primaryColor = Colors.green;
  const fontFamily = 'Urbanist';
  final colorSwatch = ColorScheme.fromSwatch(
    primarySwatch: primaryColor,
    accentColor: Colors.green[700],
    backgroundColor: Colors.grey[50],
  );

  const textTheme = TextTheme(
    titleLarge: TextStyle(color: Colors.black),
  );
  final appBarTheme = AppBarTheme(
    titleTextStyle: TextStyle(
        fontSize: 20, color: colorSwatch.onPrimary, fontFamily: fontFamily),
    color: primaryColor,
    iconTheme: const IconThemeData(color: Colors.white),
  );

  final dialogTheme = DialogTheme(
      backgroundColor: Colors.white, surfaceTintColor: Colors.grey[200]);

  const inputDecorationTheme = InputDecorationTheme(
    focusedBorder:
        OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
    enabledBorder:
        OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
    disabledBorder:
        OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
    errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
  );

  final cardTheme =
      CardTheme(color: Colors.grey[100], surfaceTintColor: Colors.white);

  final elevatedButton = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold)),
  );

  final outlinedButton = OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.white,
    side: const BorderSide(color: primaryColor),
    textStyle: const TextStyle(fontWeight: FontWeight.bold),
  ));

  final checkboxTheme = CheckboxThemeData(
    checkColor: MaterialStateProperty.all(Colors.white),
    side: BorderSide(color: Colors.grey[700]!),
  );

  return ThemeData(
    primarySwatch: primaryColor,
    colorScheme: colorSwatch,
    fontFamily: fontFamily,
    textTheme: textTheme,
    appBarTheme: appBarTheme,
    dialogTheme: dialogTheme,
    inputDecorationTheme: inputDecorationTheme,
    cardTheme: cardTheme,
    elevatedButtonTheme: elevatedButton,
    outlinedButtonTheme: outlinedButton,
    checkboxTheme: checkboxTheme,
  );
}

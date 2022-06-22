import 'package:flutter/material.dart';

class Section {
  final int nbSections = 6;

  static String letter(index) {
    return 'MÉTIER'[index];
  }

  static MaterialColor color(index) {
    return [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
    ][index];
  }
}

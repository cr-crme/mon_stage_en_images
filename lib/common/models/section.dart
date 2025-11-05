import 'package:flutter/material.dart';

mixin Section {
  static const int nbSections = 6;

  static String letter(int index) {
    return name(index)[0];
  }

  static String name(int index) {
    return [
      'Matières et produits',
      'Équipements',
      'Tâches et exigences',
      'Individu',
      'Environnement de travail',
      'Ressources humaines',
    ][index];
  }

  static MaterialColor color(int index) {
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

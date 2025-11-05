import 'package:flutter/material.dart';

mixin Section {
  static const int nbSections = 6;

  static String letter(index) {
    return name(index)[0];
  }

  static String name(index) {
    return [
      'Matières et produits',
      'Équipements',
      'Tâches et exigences',
      'Individu',
      'Environnement de travail',
      'Ressources humaines',
    ][index];
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

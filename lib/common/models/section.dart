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

  static String description(int index) {
    return [
      '''Ensemble des matières manipulées ou à transformer'''
          ''' dans la réalisation de la tâche. Il peut s’agir de produits commerciaux'''
          ''' (étiquetés) ou de substances présentes ou générées lors de la réalisation de l’activité'''
          ''' (poussières de bois, gaz d’échappement, pesticides, etc.). ''',
      '''Machines, outils, équipements (y compris les équipements de protection individuelle) utilisés lors de l’activité.'''
          ''' Les procédures liées à la maintenance, l’entretien et la disponibilité des appareils sont aussi concernées.''',
      '''Concerne la tâche prescrite, c’est-à-dire la consigne reçue par l’élève,'''
          ''' mais également les exigences qui s’y rapportent : attentes en termes de productivité,'''
          ''' de qualité du livrable, de quantité ou autre critère de performance imposé par l’employeur''',
      '''Caractéristiques personnelles de l’élève, qui peuvent affecter son activité de travail'''
          ''' : âge, genre, sexe, croissance, caractéristiques physiques, capacités ou difficultés motrices.'''
          ''' Ces composantes dépassent l’aspect biologique : il est primordial de considérer l’expérience'''
          ''' dans la tâche, l’intérêt pour celle-ci, les capacités d’apprentissage,'''
          ''' l’environnement familial, les représentations sur le travail, la santé, la sécurité ''',
      '''Décrit les caractéristiques physiques du poste de travail (aménagement, disposition spatiale)'''
          ''' ainsi que ses facteurs d’ambiance (lumière, bruit, température, etc.).  ''',
      '''Toutes les personnes qui représentent des ressources ou des contraintes potentielles'''
          ''' pour l’élève en milieu de stage (collègues, superviseur, clients, …). '''
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

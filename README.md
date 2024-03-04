# CRCRME - Mon stage en images

## Installation

Il est important de suivre les étapes suivante suite au clonage de ce dépôt git afin de pouvoir compiler sans problème :  

### Submodules Git

Rouler la commande suivante pour cloner les dépôts nécessaires pour compiler l'application.

    git submodule update --init

### Firebase

1. Installer le [CLI Firebase](https://firebase.google.com/docs/cli#setup_update_cli). La façon la plus rapide, si Node.js est déjà installé, est avec `npm` :    

        npm install -g firebase-tools

2. Installer le [CLI FlutterFire](https://pub.dev/packages/flutterfire_cli) à l'aide de `dart`.

        dart pub global activate flutterfire_cli

3. Se connecter avec un compte ayant accès au projet Firebase et configurer le projet avec les paramètres par défaut.

        firebase login
        firebase init
        flutterfire configure --project=monstageenimages

Pour plus d'informations, visitez [cette page](https://firebase.google.com/docs/flutter/setup).

### Firebase Emulators

L'application ne modifie pas directement les données contenues sur le Cloud. À la place, tout les composants Firebase sont connectés à un emulateur local.  
Il existe deux façons faciles de les démarrer :

1. Commencer à debogger avec VS Code (`F5` par défaut).
2. Via la ligne de commande : `firebase emulators:start`

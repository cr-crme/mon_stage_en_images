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

## Release

### Android

Pour générer un fichier APK, il suffit de rouler la commande suivante :

    flutter build appbundle

Si une erreur arrive, il est probable que vous ayez oublié de configurer votre environnement pour la compilation Android. Dans le dossier `android/`, il est nécessaire de créer un fichier `key.properties` contenant les informations suivantes (important: un "\" dans le mot de passe doit s'écrire avec le caractère d'échappement) :

    storePassword=...  
    keyPassword=...
    keyAlias=mon stage en images
    storeFile=...

Si vous n'avez pas le fichier pour `storeFile`, il faut en faire la demande à un membre de l'équipe sur GitHub.

### iOS

Pour générer un fichier IPA, il suffit de rouler la commande suivante :

    flutter build ipa

Il est normal que la commande crash à la fin puisque nous n'avons pas accès au cloud. Suivre le lien qui est proposé par la console qui devrait ouvrir XCode. Cliquer ensuite sur `Distribuer App`, puis `Custom`, puis `App Store Connect`, puis `Export`. Après un moment d'attente assurez vous que dans les options proposés seul `TestFlight internal testing only` n'est pas coché puis faire `Next`, Sélectionner `Manually manage signing`. 
À cette étape, vous devez avoir un certificat de distribution et un profil émis par Apple. Si ce n'est pas le cas, demandez à un membre de l'équipe de vous les fournir en visitant le site web de `App store connect, Certificates, Identifiers & Profiles` (même endroit pour générer le app bundle). Appuyer sur `Next`, puis `Export` et choisissez un endroit pour sauvegarder le fichier.

Utiliser enfin `Transporter` pour envoyer le fichier sur `App Store Connect`.

ATTENTION: Vous allez recevoir un courriel de la part d'Apple environ 5 à 10 minutes après que le téléchargement ait réussi. Dans ce courriel, il y aura la mention de réussite ou échec de la soumission. Si c'est un échec, vous ne verrez pas le build dans votre liste de builds sur `App Store Connect`. Corrigez les erreurs et reprenez du début. Si c'est un succès, le build devrait immédiatement apparaître dans la liste de builds sur `App Store Connect`. Vous pouvez alors le sélectionner pour le soumettre à la revue.
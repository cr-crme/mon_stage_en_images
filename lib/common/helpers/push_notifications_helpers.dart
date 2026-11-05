import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/helpers/shared_preferences_manager.dart';
import 'package:mon_stage_en_images/common/providers/database.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class PushNotificationsHelpers {
  ///
  /// NOTE: Send notifications is done using Firebase Cloud Functions (see functions folder).
  ///

  ///
  /// This method should be called once when the app starts to set up push notifications.
  /// It will request permissions if needed and listen to incoming notifications.
  ///
  static Future<void> setupPushNotifications(BuildContext context) async {
    if (kIsWeb) return;

    await _listenToPushNotifications();

    final fcm = FirebaseMessaging.instance;
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    switch (settings.authorizationStatus) {
      case AuthorizationStatus.notDetermined:
        await fcm.requestPermission();
        break;
      case AuthorizationStatus.denied:
      case AuthorizationStatus.deniedPermanently:
        {
          if (SharedPreferencesController.instance.showPermissionRefused) {
            SharedPreferencesController.instance.showPermissionRefused = false;
            if (!context.mounted) return;
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Notifications désactivées'),
                content: const Text(
                    'Les notifications push sont désactivées sur votre appareil.\n'
                    'Pour les activer, veuillez aller dans les paramètres de votre appareil.'),
                actions: [
                  TextButton(
                      onPressed: () async => await openAppSettings(),
                      child: Text('Paramètres')),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Continuer'),
                  ),
                ],
              ),
            );
          }
          break;
        }
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        break;
    }

    // getToken() is deprecated in favor of register()/onRegistered, but those
    // yield a Firebase Installation ID (FID), not an FCM registration token.
    // The cloud function (functions/main.py) sends via MulticastMessage(tokens=...),
    // which requires FCM tokens, so switching would break notifications until
    // the backend is migrated to FID-based direct send.
    final token = await fcm.getToken();
    if (!context.mounted || token == null) return;

    final database = Provider.of<Database>(context, listen: false);
    final user = database.currentUser;
    if (user == null) throw Exception('No user is currently logged in.');

    final userTokens = [...user.pushNotificationsTokens];
    if (!userTokens.contains(token)) {
      userTokens.add(token);
      await database.modifyUser(
          user: user,
          newInfo: user.copyWith(pushNotificationsTokens: userTokens));
    }
  }

  static Future<void> _listenToPushNotifications() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // This can be used to show in-app notifications if needed (e.g. snackbar)
        // and navigate to specific screens based on message data.
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // This can be used to navigate to specific screens when the app is opened
      // from a push notification.
    });
  }
}

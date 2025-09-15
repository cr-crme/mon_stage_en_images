import 'package:flutter/material.dart';

enum FirebasePasswordResetStatus {
  success(
    "Un courriel de réinitialisation a été envoyé à l'adresse fournie",
  ),
  userNotFound(
    "Votre adresse courriel n'est associée à aucun compte utilisateur",
  ),
  invalidEmail(
    "L'adresse courriel fournie n'est pas valide",
  ),
  unrecognizedError(
    "Une erreur inconnue est survenue",
  );

  const FirebasePasswordResetStatus(this.message);
  final String message;
  static FirebasePasswordResetStatus switchCodeToStatus(String? code) {
    debugPrint("code from firebase : $code");
    return switch (code) {
      "user-not-found" => FirebasePasswordResetStatus.userNotFound,
      "invalid-email" => FirebasePasswordResetStatus.invalidEmail,
      null => FirebasePasswordResetStatus.success,
      _ => FirebasePasswordResetStatus.unrecognizedError,
    };
  }
}

extension SwitchCodeToStatus on FirebasePasswordResetStatus {}

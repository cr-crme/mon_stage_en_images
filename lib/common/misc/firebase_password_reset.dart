import 'package:logging/logging.dart';

final _logger = Logger('FirebasePasswordReset');

enum FirebasePasswordResetStatus {
  success(
    "Un courriel de réinitialisation a été envoyé à l'adresse fournie",
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
    _logger.info("Response from firebase : $code");
    return switch (code) {
      "invalid-email" => FirebasePasswordResetStatus.invalidEmail,
      null => FirebasePasswordResetStatus.success,
      _ => FirebasePasswordResetStatus.unrecognizedError,
    };
  }
}

extension SwitchCodeToStatus on FirebasePasswordResetStatus {}

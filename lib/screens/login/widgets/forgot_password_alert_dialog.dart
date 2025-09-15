import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/misc/email_validator.dart';
import 'package:mon_stage_en_images/common/models/database.dart';
import 'package:provider/provider.dart';

class ForgotPasswordAlertDialog extends StatefulWidget {
  const ForgotPasswordAlertDialog({super.key, this.email});

  final String? email;

  @override
  State<ForgotPasswordAlertDialog> createState() =>
      _ForgotPasswordAlertDialogState();
}

class _ForgotPasswordAlertDialogState extends State<ForgotPasswordAlertDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _email;
  String? _validationError;
  bool _isloading = false;

  Future<String?> _asyncValidateEmail(String? value) async {
    if (value == null || value.isEmpty) return 'Entrez une adresse courriel';
    if (!value.isValidEmail())
      // ignore: curly_braces_in_flow_control_structures
      return 'Merci d\'entrer une adresse au format "adresse@courriel.com"';

    //TODO Décider si sécuritaire de vérifier l'existence du courriel.
    //TODO Si sécuritaire, autoriser .userFromEmail() quand user == null dans les règles firebase
    final existingUser = await Future.delayed(Duration(seconds: 1),
        () => value == 'ploufi@ploufi.com' ? null : 'ploufi');

    // final existingUser = await Provider.of<Database>(context, listen: false).userFromEmail(value);
    return existingUser == null
        ? 'Votre courriel n\'est associé à aucun compte utilisateur.'
        : null;
  }

  _finalize() async {
    _formKey.currentState?.save();

    _isloading = true;
    setState(() {});
    _validationError = await _asyncValidateEmail(_email);

    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    if (mounted) {
      final database = Provider.of<Database>(context, listen: false);
      if (database.currentUser != null) {
        Navigator.pop(context);
      }

      final resetPasswordStatuts =
          await Provider.of<Database>(context, listen: false)
              .resetPassword(email: _email);

      Navigator.pop(context, resetPasswordStatuts);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text('Récupérer votre mot de passe'),
        content: SingleChildScrollView(
          padding: EdgeInsets.all(8),
          child: Form(
            key: _formKey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 16,
                children: [
                  Text.rich(TextSpan(
                      text:
                          'Indiquez l\'adresse courriel utilisée lors de votre inscription '
                          'pour recevoir',
                      children: [
                        TextSpan(
                            text: ' un courriel de réinitialisation',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: ' de vos accès.')
                      ])),
                  SizedBox(
                    height: 4,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Adresse courriel', errorMaxLines: 3),
                    initialValue: widget.email,
                    validator: (value) {
                      return _validationError;
                    },
                    onSaved: (value) async {
                      _email = value;
                      _validationError = await _asyncValidateEmail(value);
                    },
                  ),
                  Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    spacing: 8,
                    children: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Annuler')),
                      ElevatedButton(
                          onPressed: _isloading
                              ? null
                              : () async {
                                  await _finalize();
                                  setState(() {
                                    _isloading = false;
                                  });
                                },
                          child: _isloading
                              ? CircularProgressIndicator.adaptive()
                              : Text('Envoyer le courriel')),
                    ],
                  )
                ]),
          ),
        ));
  }
}

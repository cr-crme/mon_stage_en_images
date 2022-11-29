import 'package:flutter/material.dart';

class ChangePasswordAlertDialog extends StatefulWidget {
  const ChangePasswordAlertDialog({
    super.key,
  });

  @override
  State<ChangePasswordAlertDialog> createState() =>
      _ChangePasswordAlertDialogState();
}

class _ChangePasswordAlertDialogState extends State<ChangePasswordAlertDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _password;

  void _finalize() {
    _formKey.currentState!.save();
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    Navigator.pop(context, _password);
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Ajouter un mot de passe';
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Svp, changer votre mot de passe'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Nouveau mot de passe'),
                validator: _validatePassword,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.visiblePassword,
                onSaved: (value) => _password = value,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Copier le mot de passe'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Copier le mot de passe'
                    : (value != _password
                        ? 'Les mots de passe doivent correspondre'
                        : null),
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.visiblePassword,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Enregistrer',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary)),
          onPressed: () => _finalize(),
        ),
      ],
    );
  }
}

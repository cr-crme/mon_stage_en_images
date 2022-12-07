import 'package:flutter/material.dart';

import '/common/models/user.dart';

class NewUserAlertDialog extends StatefulWidget {
  const NewUserAlertDialog({
    super.key,
    required this.email,
  });

  final String email;

  @override
  State<NewUserAlertDialog> createState() => _NewUserAlertDialogState();
}

class _NewUserAlertDialogState extends State<NewUserAlertDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _firstName;
  String? _lastName;

  void _finalize({bool hasCancelled = false}) {
    if (hasCancelled) {
      Navigator.pop(context);
      return;
    }

    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    var user = User(
      firstName: _firstName!,
      lastName: _lastName!,
      email: widget.email,
      addedBy: 'Administrator',
      isStudent: false,
      shouldChangePassword: true,
    );

    Navigator.pop(context, user);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Entrez vos informations'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ajouter un prénom' : null,
                onSaved: (value) => _firstName = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ajouter un nom' : null,
                onSaved: (value) => _lastName = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Courriel'),
                initialValue: widget.email,
                enabled: false,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Annuler',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary)),
          onPressed: () => _finalize(hasCancelled: true),
        ),
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

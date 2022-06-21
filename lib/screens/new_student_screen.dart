// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:defi_photo/models/student.dart';
import 'package:flutter/material.dart';

class NewStudentScreen extends StatefulWidget {
  const NewStudentScreen({Key? key}) : super(key: key);

  @override
  State<NewStudentScreen> createState() => _NewStudentScreenState();
}

class _NewStudentScreenState extends State<NewStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _firstName;
  String? _lastName;

  void _finalize(BuildContext context, {bool hasCancelled = false}) {
    if (hasCancelled) {
      Navigator.pop(context);
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }
    Navigator.pop(
        context, Student(firstName: _firstName!, lastName: _lastName!));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Informations de l\'élève à ajouter'),
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
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Annuler'),
          onPressed: () => _finalize(context, hasCancelled: true),
        ),
        TextButton(
          child: const Text('Ajouter'),
          onPressed: () => _finalize(context),
        ),
      ],
    );
  }
}

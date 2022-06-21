import 'package:flutter/material.dart';

import '../models/company.dart';
import '../models/student.dart';

class NewStudentScreen extends StatefulWidget {
  const NewStudentScreen({Key? key}) : super(key: key);

  @override
  State<NewStudentScreen> createState() => _NewStudentScreenState();
}

class _NewStudentScreenState extends State<NewStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _firstName;
  String? _lastName;
  String? _companyName;

  void _finalize(BuildContext context, {bool hasCancelled = false}) {
    if (hasCancelled) {
      Navigator.pop(context);
      return;
    }

    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    var student = Student(firstName: _firstName!, lastName: _lastName!);
    if (_companyName != null && _companyName!.isNotEmpty) {
      student.company = Company(name: _companyName!);
    }
    Navigator.pop(context, student);
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
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Nom de l\'entreprise'),
                validator: (value) => null,
                onSaved: (value) => _companyName = value,
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

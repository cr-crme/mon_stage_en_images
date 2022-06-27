import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/models/all_answers.dart';
import '../../../common/models/company.dart';
import '../../../common/models/student.dart';
import '../../../common/providers/all_questions.dart';

class NewStudentAlertDialog extends StatefulWidget {
  const NewStudentAlertDialog({Key? key}) : super(key: key);

  @override
  State<NewStudentAlertDialog> createState() => _NewStudentAlertDialogState();
}

class _NewStudentAlertDialogState extends State<NewStudentAlertDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _firstName;
  String? _lastName;
  String? _companyName;

  void _finalize(BuildContext context, {bool hasCancelled = false}) {
    final questions = Provider.of<AllQuestions>(context, listen: false);

    if (hasCancelled) {
      Navigator.pop(context);
      return;
    }

    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    var student = Student(
      firstName: _firstName!,
      lastName: _lastName!,
      allAnswers: AllAnswers(questions: questions),
      company: Company(name: _companyName ?? ''),
    );
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
          child: Text('Annuler',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary)),
          onPressed: () => _finalize(context, hasCancelled: true),
        ),
        TextButton(
          child: Text('Ajouter',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary)),
          onPressed: () => _finalize(context),
        ),
      ],
    );
  }
}

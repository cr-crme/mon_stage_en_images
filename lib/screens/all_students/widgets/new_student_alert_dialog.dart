import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/models/all_answers.dart';
import '../../../common/models/company.dart';
import '../../../common/models/student.dart';
import '../../../common/providers/all_questions.dart';

class NewStudentAlertDialog extends StatefulWidget {
  const NewStudentAlertDialog({
    super.key,
    this.student,
    this.deleteCallback,
  });

  final Student? student;
  final Function(Student)? deleteCallback;

  @override
  State<NewStudentAlertDialog> createState() => _NewStudentAlertDialogState();
}

class _NewStudentAlertDialogState extends State<NewStudentAlertDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _companyName;

  void _finalize({bool hasCancelled = false}) {
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
      email: _email!,
      allAnswers: AllAnswers(questions: questions.toList(growable: false)),
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
                initialValue: widget.student?.firstName,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ajouter un prénom' : null,
                onSaved: (value) => _firstName = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nom'),
                initialValue: widget.student?.lastName,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ajouter un nom' : null,
                onSaved: (value) => _lastName = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Courriel'),
                initialValue: widget.student?.email,
                keyboardType: TextInputType.emailAddress,
                enabled: widget.student?.email == null,
                validator: (value) => value == null || value.isEmpty
                    ? 'Ajouter un courriel'
                    : RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value)
                        ? null
                        : 'Courriel non valide',
                onSaved: (value) => _email = value,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Nom de l\'entreprise'),
                initialValue: widget.student?.company.name,
                validator: (value) => value == null || value.isEmpty
                    ? 'Ajouter un nom d\'entreprise'
                    : null,
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
          onPressed: () => _finalize(hasCancelled: true),
        ),
        TextButton(
          child: Text(widget.student == null ? 'Ajouter' : 'Modifier',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary)),
          onPressed: () => _finalize(),
        ),
        if (widget.student != null && widget.deleteCallback != null)
          IconButton(
            onPressed: () {
              _finalize(hasCancelled: true);
              widget.deleteCallback!(widget.student!);
            },
            icon: const Icon(Icons.delete),
          ),
      ],
    );
  }
}

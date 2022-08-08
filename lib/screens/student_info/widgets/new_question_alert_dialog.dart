import 'package:flutter/material.dart';

import '../../../common/models/enum.dart';
import '../../../common/models/question.dart';
import '../../../common/models/student.dart';

class NewQuestionAlertDialog extends StatefulWidget {
  const NewQuestionAlertDialog({
    Key? key,
    required this.section,
    required this.student,
    required this.title,
    required this.canDelete,
  }) : super(key: key);

  final int section;
  final Student? student;
  final String? title;
  final bool canDelete;

  @override
  State<NewQuestionAlertDialog> createState() => _NewQuestionAlertDialogState();
}

class _NewQuestionAlertDialogState extends State<NewQuestionAlertDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _text;

  void _finalize(BuildContext context, {bool hasCancelled = false}) {
    if (hasCancelled) {
      Navigator.pop(context);
      return;
    }

    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    var question = Question(_text!,
        section: widget.section,
        defaultTarget: widget.student != null ? Target.individual : Target.all);

    Navigator.pop(context, question);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Form(key: _formKey, child: _showQuestionTextInput()),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: Text(widget.title == null ? 'Ajouter' : 'Modifier',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          onPressed: () => _finalize(context),
        ),
        OutlinedButton(
          child: Text(
            'Annuler',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary),
          ),
          onPressed: () => _finalize(context, hasCancelled: true),
        ),
        if (widget.title != null && widget.canDelete)
          const IconButton(onPressed: null, icon: Icon(Icons.delete)),
      ],
    );
  }

  TextFormField _showQuestionTextInput() {
    return TextFormField(
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: 3,
      decoration: const InputDecoration(labelText: 'Libellé de la question'),
      validator: (value) =>
          value == null || value.isEmpty ? 'Ajouter une question' : null,
      initialValue: widget.title,
      onSaved: (value) => _text = value,
    );
  }
}

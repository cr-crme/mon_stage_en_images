import 'package:flutter/material.dart';

import '/common/models/enum.dart';
import '/common/models/question.dart';
import '/common/models/student.dart';
import '/common/widgets/are_you_sure_dialog.dart';

class NewQuestionAlertDialog extends StatefulWidget {
  const NewQuestionAlertDialog({
    super.key,
    required this.section,
    required this.student,
    required this.title,
    required this.deleteCallback,
  });

  final int section;
  final Student? student;
  final String? title;
  final Function? deleteCallback;

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
        if (widget.title != null && widget.deleteCallback != null)
          IconButton(
              onPressed: _confirmDeleting, icon: const Icon(Icons.delete)),
        OutlinedButton(
          child: Text(
            'Annuler',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary),
          ),
          onPressed: () => _finalize(context, hasCancelled: true),
        ),
        ElevatedButton(
          child: Text(widget.title == null ? 'Ajouter' : 'Enregistrer',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          onPressed: () => _finalize(context),
        ),
      ],
    );
  }

  Future<void> _confirmDeleting() async {
    final sure = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AreYouSureDialog(
          title: 'Suppression d\'une question',
          content: 'Êtes-vous certain(e) de vouloir supprimer cette question?',
        );
      },
    );
    if (!sure! || !mounted) return;

    widget.deleteCallback!();
    Navigator.pop(context);
    return;
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

import 'package:defi_photo/common/providers/all_students.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enum.dart';
import '/common/models/question.dart';
import '/common/models/student.dart';
import '/common/widgets/are_you_sure_dialog.dart';

class NewQuestionAlertDialog extends StatefulWidget {
  const NewQuestionAlertDialog({
    super.key,
    required this.section,
    required this.student,
    required this.question,
    required this.deleteCallback,
  });

  final int section;
  final Student? student;
  final Question? question;
  final Function? deleteCallback;

  @override
  State<NewQuestionAlertDialog> createState() => _NewQuestionAlertDialogState();
}

class _NewQuestionAlertDialogState extends State<NewQuestionAlertDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _text;
  final Map<Student, bool> _questionStatus = {};

  @override
  void initState() {
    super.initState();
    final students = Provider.of<AllStudents>(context, listen: false);
    for (final student in students) {
      _questionStatus[student] = widget.question == null
          ? false
          : student.allAnswers[widget.question]?.isActive ?? false;
    }
  }

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

    Navigator.pop(context, [question, _questionStatus]);
  }

  Widget _buildStudentTile(Student student, Question? question) {
    return GestureDetector(
      onTap: () {
        _questionStatus[student] = !_questionStatus[student]!;
        setState(() {});
      },
      child: Row(children: [
        Checkbox(
            value: _questionStatus[student],
            onChanged: (value) {
              _questionStatus[student] = value!;
              setState(() {});
            }),
        Text('${student.firstName} ${student.lastName}'),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final students = Provider.of<AllStudents>(context, listen: false).toList();
    students.sort(
        (a, b) => a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase()));

    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(key: _formKey, child: _showQuestionTextInput()),
            const Divider(),
            const Text('Question activée pour :'),
            ...students.map<Widget>(
                (student) => _buildStudentTile(student, widget.question)),
          ],
        ),
      ),
      actions: <Widget>[
        if (widget.question?.text != null && widget.deleteCallback != null)
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
          child: Text(widget.question?.text == null ? 'Ajouter' : 'Enregistrer',
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
      initialValue: widget.question?.text,
      onSaved: (value) => _text = value,
    );
  }
}

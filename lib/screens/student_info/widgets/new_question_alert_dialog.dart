import 'package:flutter/material.dart';

import '../../../common/models/enum.dart';
import '../../../common/models/question.dart';
import '../../../common/models/student.dart';
import '../../../common/widgets/grouped_radio_button.dart';

class NewQuestionAlertDialog extends StatefulWidget {
  const NewQuestionAlertDialog(
      {Key? key, required this.section, required this.student})
      : super(key: key);

  final int section;
  final Student? student;

  @override
  State<NewQuestionAlertDialog> createState() => _NewQuestionAlertDialogState();
}

class _NewQuestionAlertDialogState extends State<NewQuestionAlertDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _text;
  Target _target = Target.all;
  QuestionType _questionType = QuestionType.photo;

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
        type: _questionType, section: widget.section, defaultTarget: _target);

    Navigator.pop(context, question);
  }

  void _setTarget(value) {
    _target = value;
    setState(() {});
  }

  void _setQuestionType(value) {
    _questionType = value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Question à ajouter'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _showQuestionTextInput(),
              const SizedBox(height: 25),
              const Text('Le type de la question est :'),
              _showQuestionType(context),
              const SizedBox(height: 25),
              Text(widget.student == null
                  ? 'Activer la question pour'
                  : 'Ajouter la question à :'),
              _showAddTo(context),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            'Annuler',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary),
          ),
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

  TextFormField _showQuestionTextInput() {
    return TextFormField(
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: 3,
      decoration: const InputDecoration(labelText: 'Libellé de la question'),
      validator: (value) =>
          value == null || value.isEmpty ? 'Ajouter une question' : null,
      onSaved: (value) => _text = value,
    );
  }

  Row _showAddTo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GroupedRadioButton<Target>(
            title: widget.student == null
                ? const Text('Personne')
                : Text(widget.student.toString()),
            value: widget.student == null ? Target.none : Target.individual,
            groupValue: _target,
            onChanged: _setTarget),
        GroupedRadioButton<Target>(
            title: const Text('Tous'),
            value: Target.all,
            groupValue: _target,
            onChanged: _setTarget),
      ],
    );
  }

  Row _showQuestionType(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GroupedRadioButton<QuestionType>(
            title: const Text('Texte'),
            value: QuestionType.text,
            groupValue: _questionType,
            onChanged: _setQuestionType),
        GroupedRadioButton<QuestionType>(
            title: const Text('Photo'),
            value: QuestionType.photo,
            groupValue: _questionType,
            onChanged: _setQuestionType),
      ],
    );
  }
}

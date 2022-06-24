import 'package:flutter/material.dart';

import '../../../common/models/enum.dart';
import '../../../common/models/question.dart';
import '../../../common/models/student.dart';

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
        needPhoto: _questionType == QuestionType.photo,
        needText: _questionType == QuestionType.text,
        section: widget.section);

    Navigator.pop(context, {'question': question, 'target': _target});
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
              const Text('Ajouter la question à :'),
              _showAddTo(context),
              const SizedBox(height: 25),
              const Text('La réponse doit être de type :'),
              _showQuestionType(context),
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
        addRadioButon<Target>(context,
            title: Text(widget.student.toString()),
            value: Target.individual,
            groupValue: _target,
            onChanged: _setTarget),
        addRadioButon<Target>(context,
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
        addRadioButon<QuestionType>(context,
            title: const Text('Texte'),
            value: QuestionType.text,
            groupValue: _questionType,
            onChanged: _setQuestionType),
        addRadioButon<QuestionType>(context,
            title: const Text('Photo'),
            value: QuestionType.photo,
            groupValue: _questionType,
            onChanged: _setQuestionType),
      ],
    );
  }

  Flexible addRadioButon<T>(
    BuildContext context, {
    required title,
    required value,
    required groupValue,
    required onChanged,
  }) {
    return Flexible(
      child: ListTile(
        leading: Radio<T>(
          groupValue: groupValue,
          onChanged: onChanged,
          value: value,
          activeColor: Theme.of(context).colorScheme.secondary,
        ),
        title: Flexible(child: title),
        horizontalTitleGap: 0,
        contentPadding: const EdgeInsets.all(0),
        onTap: () => onChanged(value),
      ),
    );
  }
}

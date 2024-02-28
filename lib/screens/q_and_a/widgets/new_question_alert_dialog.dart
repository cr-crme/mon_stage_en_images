import 'package:defi_photo/common/models/database.dart';
import 'package:defi_photo/common/models/enum.dart';
import 'package:defi_photo/common/models/question.dart';
import 'package:defi_photo/common/models/user.dart';
import 'package:defi_photo/common/providers/all_answers.dart';
import 'package:defi_photo/common/providers/speecher.dart';
import 'package:defi_photo/common/widgets/animated_icon.dart';
import 'package:defi_photo/common/widgets/are_you_sure_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewQuestionAlertDialog extends StatefulWidget {
  const NewQuestionAlertDialog({
    super.key,
    required this.section,
    required this.student,
    required this.question,
    this.isQuestionModifiable = true,
    required this.deleteCallback,
  });

  final int section;
  final User? student;
  final Question? question;
  final bool isQuestionModifiable;
  final Function? deleteCallback;

  @override
  State<NewQuestionAlertDialog> createState() => _NewQuestionAlertDialogState();
}

class _NewQuestionAlertDialogState extends State<NewQuestionAlertDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isVoiceRecording = false;
  final _fieldText = TextEditingController();
  String? _text;
  final Map<String, bool> _questionStatus = {};

  @override
  void initState() {
    super.initState();
    final answers = Provider.of<AllAnswers>(context, listen: false);

    // If [student] is null, then fetch for all the students
    final students = widget.student == null
        ? Provider.of<Database>(context, listen: false).myStudents
        : [widget.student!];

    for (final student in students) {
      _questionStatus[student.id] = widget.question == null
          ? false
          : answers
                  .fromQuestionAndStudent(widget.question!, student.id)
                  ?.isActive ??
              false;
    }
    _fieldText.text = widget.question?.text ?? "";
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

  Widget _buildAllStudentsTile() {
    var isAllActive = true;
    for (final key in _questionStatus.keys) {
      if (!_questionStatus[key]!) {
        isAllActive = false;
        break;
      }
    }

    return GestureDetector(
      onTap: () {
        for (final key in _questionStatus.keys) {
          _questionStatus[key] = !isAllActive;
        }
        setState(() {});
      },
      child: Row(children: [
        Checkbox(
            value: isAllActive,
            onChanged: (value) {
              for (final key in _questionStatus.keys) {
                _questionStatus[key] = !isAllActive;
              }
              setState(() {});
            }),
        const Text(
          'Tous les élèves',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ]),
    );
  }

  Widget _buildStudentTile(User student) {
    return GestureDetector(
      onTap: () {
        _questionStatus[student.id] = !_questionStatus[student.id]!;
        setState(() {});
      },
      child: Row(children: [
        Checkbox(
            value: _questionStatus[student.id],
            onChanged: (value) {
              _questionStatus[student.id] = value!;
              setState(() {});
            }),
        Text('${student.firstName} ${student.lastName}'),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final students =
        Provider.of<Database>(context, listen: false).myStudents.toList();
    students.sort(
        (a, b) => a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase()));

    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(key: _formKey, child: _showQuestionTextInput()),
            if (!widget.isQuestionModifiable)
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                    'Il n\'est pas possible de modifier le libellé d\'une question '
                    'si au moins un élève a déjà répondu',
                    style: TextStyle(color: Colors.grey)),
              ),
            const Divider(),
            const Text('Question activée pour :'),
            _buildAllStudentsTile(),
            ...students.map<Widget>((student) => _buildStudentTile(student)),
          ],
        ),
      ),
      actions: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widget.question?.text != null && widget.deleteCallback != null)
              Tooltip(
                message: widget.question!.canBeDeleted
                    ? ''
                    : 'Il n\'est pas possible de supprimer\n'
                        'les questions par défaut',
                child: IconButton(
                    onPressed:
                        widget.question!.canBeDeleted ? _confirmDeleting : null,
                    icon: const Icon(Icons.delete)),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  child: const Text('Annuler'),
                  onPressed: () => _finalize(context, hasCancelled: true),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed:
                      _isVoiceRecording ? null : () => _finalize(context),
                  child: Text(widget.question?.text == null
                      ? 'Ajouter'
                      : 'Enregistrer'),
                ),
              ],
            ),
          ],
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
    if (!sure!) return;

    widget.deleteCallback!();

    if (mounted) Navigator.pop(context);
    return;
  }

  @override
  void dispose() {
    super.dispose();
    _fieldText.dispose();
  }

  void _dictateMessage() {
    final speecher = Provider.of<Speecher>(context, listen: false);
    speecher.startListening(
        onResultCallback: _onDictatedMessage,
        onErrorCallback: _terminateDictate);
    _isVoiceRecording = true;
    setState(() {});
  }

  void _terminateDictate() {
    final speecher = Provider.of<Speecher>(context, listen: false);
    speecher.stopListening();
    _isVoiceRecording = false;
    setState(() {});
  }

  void _onDictatedMessage(String message) {
    _fieldText.text += ' $message';
    _terminateDictate();
  }

  Widget _showQuestionTextInput() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Libellé de la question',
              suffixIcon: GestureDetector(
                  onTapDown: (_) => _dictateMessage(),
                  child: _isVoiceRecording
                      ? const CustomAnimatedIcon(
                          maxSize: 25,
                          minSize: 20,
                          color: Colors.red,
                        )
                      : const CustomStaticIcon(
                          boxSize: 25,
                          iconSize: 20,
                          color: Colors.black87,
                        )),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Ajouter une question' : null,
            onSaved: (value) => _text = value,
            enabled: widget.isQuestionModifiable,
            style: TextStyle(
                color:
                    widget.isQuestionModifiable ? Colors.black : Colors.grey),
            controller: _fieldText,
          ),
        ),
      ],
    );
  }
}

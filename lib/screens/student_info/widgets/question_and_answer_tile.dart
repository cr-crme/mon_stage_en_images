import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './discussion_list_view.dart';
import '../../../common/models/enum.dart';
import '../../../common/models/question.dart';
import '../../../common/providers/all_questions.dart';
import '../../../common/providers/all_students.dart';
import '../../../common/widgets/are_you_sure_dialog.dart';
import '../../../common/widgets/grouped_radio_button.dart';

class QuestionAndAnswerTile extends StatefulWidget {
  const QuestionAndAnswerTile(
    this.question, {
    Key? key,
    required this.studentId,
    required this.onStateChange,
    required this.isActive,
  }) : super(key: key);

  final String? studentId;
  final Question question;
  final Function(VoidCallback) onStateChange;
  final bool isActive;

  @override
  State<QuestionAndAnswerTile> createState() => _QuestionAndAnswerTileState();
}

class _QuestionAndAnswerTileState extends State<QuestionAndAnswerTile> {
  var _isExpanded = false;

  void _expand() {
    _isExpanded = !_isExpanded;

    setState(() {});
  }

  void onStateChange(VoidCallback func) {
    _isExpanded = false;
    widget.onStateChange(() {});
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Column(
        children: [
          ListTile(
            title: QuestionPart(
              question: widget.question,
              isActive: widget.isActive,
            ),
            trailing:
                Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            onTap: _expand,
          ),
          if (_isExpanded)
            AnswerPart(
              widget.question,
              onStateChange: onStateChange,
              studentId: widget.studentId,
            ),
        ],
      ),
    );
  }
}

class QuestionPart extends StatelessWidget {
  const QuestionPart({
    Key? key,
    required this.question,
    required this.isActive,
  }) : super(key: key);

  final Question question;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Text(question.text,
        style: TextStyle(color: isActive ? Colors.black : Colors.grey));
  }
}

class AnswerPart extends StatelessWidget {
  const AnswerPart(this.question,
      {Key? key, required this.onStateChange, required this.studentId})
      : super(key: key);

  final String? studentId;
  final Function(VoidCallback) onStateChange;
  final Question question;

  @override
  Widget build(BuildContext context) {
    final students = Provider.of<AllStudents>(context, listen: false);
    final student = studentId == null ? null : students[studentId];
    final answer = student == null ? null : student.allAnswers[question];

    late final bool isActive;
    if (answer != null) {
      isActive = answer.isActive;
    } else {
      // Only active if active for all
      var indexInactive = students.indexWhere(
        (s) {
          final answer = s.allAnswers[question];
          return answer == null ? false : !answer.isActive;
        },
      );
      isActive = indexInactive < 0;
    }

    return Container(
      padding: const EdgeInsets.only(left: 40, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (studentId == null) _QuestionTypeChooser(question: question),
          if (isActive &&
              question.type == QuestionType.photo &&
              studentId != null)
            _showPhoto(answer),
          if (isActive &&
              studentId != null &&
              question.type == QuestionType.text)
            _showWrittenAnswer(answer),
          if (isActive && studentId != null) const SizedBox(height: 12),
          if (isActive && studentId != null) DiscussionListView(answer: answer),
          _ShowStatus(
            studentId: studentId,
            question: question,
            onStateChange: onStateChange,
            initialStatus: isActive,
          ),
        ],
      ),
    );
  }

  Widget _showPhoto(answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Photo : ', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        answer!.photoUrl == null
            ? const Center(
                child: Text('En attente de la photo de l\'étudiant',
                    style: TextStyle(color: Colors.red)))
            : Container(
                padding: const EdgeInsets.only(left: 15),
                child: FutureBuilder(builder: (context, snapshot) {
                  return snapshot.connectionState == ConnectionState.waiting
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Image.network(
                          answer!.photoUrl!,
                          fit: BoxFit.cover,
                        );
                }),
              ),
      ],
    );
  }

  Widget _showWrittenAnswer(answer) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Réponse écrite : ', style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 4),
      answer!.text == null
          ? const Center(
              child: Text('En attente de la réponse de l\'étudiant',
                  style: TextStyle(color: Colors.red)))
          : Container(
              padding: const EdgeInsets.only(left: 15),
              child: Row(
                children: [Flexible(child: Text(answer!.text!.toString()))],
              ),
            )
    ]);
  }
}

class _QuestionTypeChooser extends StatefulWidget {
  const _QuestionTypeChooser({
    Key? key,
    required this.question,
  }) : super(key: key);

  final Question question;

  @override
  State<_QuestionTypeChooser> createState() => _QuestionTypeChooserState();
}

class _QuestionTypeChooserState extends State<_QuestionTypeChooser> {
  late QuestionType _questionType = QuestionType.photo;

  @override
  Widget build(BuildContext context) {
    _questionType = widget.question.type;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(child: Text('Le type de question est : ')),
        GroupedRadioButton<QuestionType>(
          title: const Text('Texte'),
          value: QuestionType.text,
          groupValue: _questionType,
          onChanged: (value) => _setQuestionType(context, value),
        ),
        GroupedRadioButton<QuestionType>(
          title: const Text('Photo'),
          value: QuestionType.photo,
          groupValue: _questionType,
          onChanged: (value) => _setQuestionType(context, value),
        ),
      ],
    );
  }

  void _setQuestionType(BuildContext context, value) async {
    final questions = Provider.of<AllQuestions>(context, listen: false);
    questions[widget.question] = widget.question.copyWith(type: value);

    _questionType = value;
    setState(() {});
  }
}

class _ShowStatus extends StatefulWidget {
  const _ShowStatus(
      {Key? key,
      required this.studentId,
      required this.onStateChange,
      required this.initialStatus,
      required this.question})
      : super(key: key);

  final String? studentId;
  final Question question;
  final bool initialStatus;
  final Function(VoidCallback) onStateChange;

  @override
  State<_ShowStatus> createState() => _ShowStatusState();
}

class _ShowStatusState extends State<_ShowStatus> {
  var _isActive = false;

  Future<void> _toggleQuestion(value) async {
    final students = Provider.of<AllStudents>(context, listen: false);
    final student =
        widget.studentId == null ? null : students[widget.studentId];

    final sure = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AreYouSureDialog(
          title: 'Confimer le choix',
          content:
              'Voulez-vous vraiment ${value ? 'activer' : 'désactiver'} cette '
              'question${widget.studentId == null ? ' pour tous' : ''}?',
        );
      },
    );

    if (!sure!) return;

    _isActive = value;
    if (student != null) {
      student.allAnswers[widget.question] =
          student.allAnswers[widget.question]!.copyWith(isActive: value);
    } else {
      for (var student in students) {
        student.allAnswers[widget.question] =
            student.allAnswers[widget.question]!.copyWith(isActive: value);
      }
    }
    setState(() {});
    widget.onStateChange(() {});
  }

  @override
  Widget build(BuildContext context) {
    _isActive = widget.initialStatus;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            _isActive
                ? 'Désactiver la question '
                    '${widget.studentId == null ? 'pour tous' : 'pour cet élève'}'
                : 'Activer la question '
                    '${widget.studentId == null ? 'pour tous' : 'pour cet élève'}',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        Switch(onChanged: _toggleQuestion, value: _isActive),
      ],
    );
  }
}

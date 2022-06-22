import 'package:flutter/material.dart';

import '../../../common/models/answer.dart';
import '../../../common/models/question.dart';

class QuestionTile extends StatefulWidget {
  const QuestionTile(this.question, {Key? key, required this.answer})
      : super(key: key);

  final Question question;
  final Answer? answer;

  @override
  State<QuestionTile> createState() => _QuestionTileState();
}

class _QuestionTileState extends State<QuestionTile> {
  var _isExpanded = false;

  void _expand() {
    _isExpanded = !_isExpanded;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: QuestionPart(widget: widget),
          trailing:
              Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
          onTap: _expand,
        ),
        if (_isExpanded) AnswerPart(widget.answer),
      ],
    );
  }
}

class QuestionPart extends StatelessWidget {
  const QuestionPart({
    Key? key,
    required this.widget,
  }) : super(key: key);

  final QuestionTile widget;

  @override
  Widget build(BuildContext context) {
    return Text(widget.question.text);
  }
}

class AnswerPart extends StatelessWidget {
  const AnswerPart(this.answer, {Key? key}) : super(key: key);

  final Answer? answer;

  @override
  Widget build(BuildContext context) {
    return answer == null
        ? const Center(
            child: Text('Cette question n\'a pas été posée à l\'élève.'))
        : SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (answer!.needPhoto) _showPhoto(),
                if (answer!.needPhoto && answer!.needText)
                  const SizedBox(height: 10),
                if (answer!.needText) _showWrittenAnswer(),
              ],
            ),
          );
  }

  Widget _showWrittenAnswer() {
    return answer!.text == null
        ? const Center(
            child: Text('En attente de la réponse de l\'étudiant',
                style: TextStyle(color: Colors.red)))
        : Text(answer!.text!);
  }

  Widget _showPhoto() {
    return answer!.photoUrl == null
        ? const Center(
            child: Text('En attente de la photo de l\'étudiant',
                style: TextStyle(color: Colors.red)))
        : Image.network(
            answer!.photoUrl!,
            fit: BoxFit.cover,
          );
  }
}

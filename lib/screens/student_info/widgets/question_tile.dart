import 'package:flutter/material.dart';

import '../../../common/models/answer.dart';
import '../../../common/models/question.dart';

class QuestionTile extends StatefulWidget {
  const QuestionTile(this.question, {Key? key}) : super(key: key);

  final Question question;

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
          title: Text(widget.question.text),
          trailing:
              Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
          onTap: _expand,
        ),
        if (_isExpanded)
          AnswerTile(Answer(
              questionId: '0',
              needPhoto: widget.question.needPhoto,
              needText: widget.question.needText)),
      ],
    );
  }
}

class AnswerTile extends StatelessWidget {
  const AnswerTile(this.answer, {Key? key}) : super(key: key);

  final Answer answer;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (answer.needPhoto) _showPhoto(),
          if (answer.needPhoto && answer.needText) const SizedBox(height: 10),
          if (answer.needText) _showWrittenAnswer(),
        ],
      ),
    );
  }

  Widget _showWrittenAnswer() {
    return answer.text == null
        ? const Center(
            child: Text('En attente de la réponse de l\'étudiant',
                style: TextStyle(color: Colors.red)))
        : Text(answer.text!);
  }

  Widget _showPhoto() {
    return answer.photoUrl == null
        ? const Center(
            child: Text('En attente de la photo de l\'étudiant',
                style: TextStyle(color: Colors.red)))
        : Image.network(
            answer.photoUrl!,
            fit: BoxFit.cover,
          );
  }
}

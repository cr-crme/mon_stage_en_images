import 'package:flutter/material.dart';

import './discussion_list_view.dart';
import '../../../common/models/answer.dart';
import '../../../common/models/question.dart';

class QuestionAndAnswerTile extends StatefulWidget {
  const QuestionAndAnswerTile(this.question, {Key? key, required this.answer})
      : super(key: key);

  final Question question;
  final Answer? answer;

  @override
  State<QuestionAndAnswerTile> createState() => _QuestionAndAnswerTileState();
}

class _QuestionAndAnswerTileState extends State<QuestionAndAnswerTile> {
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

  final QuestionAndAnswerTile widget;

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
            width: MediaQuery.of(context).size.width - 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (answer!.needPhoto) _showPhoto(),
                if (answer!.needPhoto && answer!.needText)
                  const SizedBox(height: 12),
                if (answer!.needText) _showWrittenAnswer(),
                const SizedBox(height: 12),
                DiscussionListView(answer: answer),
              ],
            ),
          );
  }

  Widget _showPhoto() {
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
                child: Image.network(
                  answer!.photoUrl!,
                  fit: BoxFit.cover,
                ),
              ),
      ],
    );
  }

  Widget _showWrittenAnswer() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Réponse écrite : ', style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 4),
      answer!.text == null
          ? const Center(
              child: Text('En attente de la réponse de l\'étudiant',
                  style: TextStyle(color: Colors.red)))
          : Container(
              padding: const EdgeInsets.only(left: 15),
              child: Text(answer!.text!.toString()),
            )
    ]);
  }
}

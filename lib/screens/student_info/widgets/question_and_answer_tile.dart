import 'package:flutter/material.dart';

import './discussion_list_view.dart';
import '../../../common/models/answer.dart';
import '../../../common/models/question.dart';

class QuestionAndAnswerTile extends StatefulWidget {
  const QuestionAndAnswerTile(
    this.question, {
    Key? key,
    required this.answer,
    required this.onStateChange,
  }) : super(key: key);

  final Question question;
  final Answer? answer;
  final Function(VoidCallback) onStateChange;

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
    var isQuestionActive = widget.answer != null && widget.answer!.isActive;
    return Column(
      children: [
        ListTile(
          title: QuestionPart(
            question: widget.question,
            isActive: isQuestionActive,
          ),
          trailing:
              Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
          onTap: _expand,
        ),
        if (_isExpanded)
          AnswerPart(widget.answer, onStateChange: widget.onStateChange),
      ],
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
  const AnswerPart(
    this.answer, {
    Key? key,
    required this.onStateChange,
  }) : super(key: key);

  final Answer? answer;
  final Function(VoidCallback) onStateChange;

  @override
  Widget build(BuildContext context) {
    var isActive = answer!.isActive;
    return Container(
      padding: const EdgeInsets.only(left: 40, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShowStatus(answer: answer, onStateChange: onStateChange),
          if (isActive && answer!.needPhoto) _showPhoto(),
          if (isActive && answer!.needPhoto && answer!.needText)
            const SizedBox(height: 12),
          if (isActive && answer!.needText) _showWrittenAnswer(),
          if (isActive) const SizedBox(height: 12),
          if (isActive) DiscussionListView(answer: answer),
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
              child: Row(
                children: [Flexible(child: Text(answer!.text!.toString()))],
              ),
            )
    ]);
  }
}

class _ShowStatus extends StatefulWidget {
  const _ShowStatus(
      {Key? key, required this.answer, required this.onStateChange})
      : super(key: key);

  final Answer? answer;
  final Function(VoidCallback) onStateChange;

  @override
  State<_ShowStatus> createState() => _ShowStatusState();
}

class _ShowStatusState extends State<_ShowStatus> {
  var _isActive = false;

  void _toggleQuestion(value) {
    _isActive = value;
    widget.answer!.isActive = value;
    setState(() {});
    widget.onStateChange(() {});
  }

  @override
  Widget build(BuildContext context) {
    _isActive = widget.answer!.isActive;
    var status = _isActive ? 'Question activée' : 'Question désactivée';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            'Statut : $status',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        Switch(onChanged: _toggleQuestion, value: _isActive),
      ],
    );
  }
}

import 'package:flutter/material.dart';

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
    return ListTile(
      title: Text(widget.question.title),
      trailing: Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
      onTap: _expand,
    );
  }
}

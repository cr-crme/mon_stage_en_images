import 'package:flutter/material.dart';

import '../providers/all_question_lists.dart';

class SectionTileInStudent extends StatefulWidget {
  const SectionTileInStudent(this.questions, this.sectionIndex, {Key? key})
      : super(key: key);

  final int sectionIndex;
  final QuestionList questions;

  @override
  State<SectionTileInStudent> createState() => _SectionTileInStudentState();
}

class _SectionTileInStudentState extends State<SectionTileInStudent> {
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
          leading: Container(
            margin: const EdgeInsets.all(2),
            padding: const EdgeInsets.all(12),
            width: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: AllQuestionList.color(widget.sectionIndex)),
            child: Text(AllQuestionList.letter(widget.sectionIndex),
                style: const TextStyle(fontSize: 25, color: Colors.white)),
          ),
          title: const Text('Questions répondues : 0 / 1'),
          trailing: IconButton(
            icon:
                Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            onPressed: _expand,
          ),
        ),
        if (_isExpanded)
          ListView.builder(
            itemBuilder: (context, index) => const ListTile(
              title: Text('coucou'),
            ),
            itemCount: widget.questions.length,
          )
      ],
    );
  }
}

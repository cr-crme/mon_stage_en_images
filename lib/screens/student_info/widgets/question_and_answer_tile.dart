import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './discussion_list_view.dart';
import '../../../common/models/answer.dart';
import '../../../common/models/enum.dart';
import '../../../common/models/question.dart';
import '../../../common/models/student.dart';
import '../../../common/providers/all_students.dart';
import '../../../common/widgets/taking_action_notifier.dart';

class QuestionAndAnswerTile extends StatefulWidget {
  const QuestionAndAnswerTile(
    this.question, {
    Key? key,
    required this.studentId,
    required this.onStateChange,
  }) : super(key: key);

  final String? studentId;
  final Question question;
  final Function(VoidCallback) onStateChange;

  @override
  State<QuestionAndAnswerTile> createState() => _QuestionAndAnswerTileState();
}

class _QuestionAndAnswerTileState extends State<QuestionAndAnswerTile> {
  var _isExpanded = false;

  Student? get _student {
    final students = Provider.of<AllStudents>(context, listen: false);
    return widget.studentId == null ? null : students[widget.studentId];
  }

  Answer? get _answer {
    final student = _student;
    return student == null ? null : student.allAnswers[widget.question];
  }

  void _expand() {
    _isExpanded = !_isExpanded;

    final answer = _answer;
    if (answer != null && answer.action == ActionRequired.fromTeacher) {
      // Flag the answer as being actionned
      _student!.allAnswers[widget.question] =
          answer.copyWith(actionRequired: ActionRequired.none);
    }

    setState(() {});
  }

  void onStateChange(VoidCallback func) {
    _isExpanded = false;
    widget.onStateChange(() {});
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final answer = _answer;
    return TakingActionNotifier(
      title: answer != null && answer.action == ActionRequired.fromTeacher
          ? ""
          : "0",
      left: 10,
      child: Card(
        elevation: 5,
        child: Column(
          children: [
            ListTile(
              title: QuestionPart(
                question: widget.question,
                studentId: widget.studentId,
              ),
              trailing: QuestionCheckmark(
                question: widget.question,
                studentId: widget.studentId,
              ),
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
      ),
    );
  }
}

class QuestionPart extends StatelessWidget {
  const QuestionPart({
    Key? key,
    required this.question,
    required this.studentId,
  }) : super(key: key);

  final Question question;
  final String? studentId;

  TextStyle _pickTextStyle(Answer? answer) {
    if (answer == null) {
      return const TextStyle();
    }

    return TextStyle(
      color: !answer.isAnswered ? Colors.red : Colors.black,
      fontWeight: answer.action == ActionRequired.fromTeacher
          ? FontWeight.bold
          : FontWeight.normal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final students = Provider.of<AllStudents>(context, listen: false);
    final student = studentId == null ? null : students[studentId];
    final answer = student == null ? null : student.allAnswers[question];

    return Text(question.text, style: _pickTextStyle(answer));
  }
}

class QuestionCheckmark extends StatefulWidget {
  const QuestionCheckmark({
    Key? key,
    required this.question,
    required this.studentId,
  }) : super(key: key);

  final Question question;
  final String? studentId;

  @override
  State<QuestionCheckmark> createState() => _QuestionCheckmarkState();
}

class _QuestionCheckmarkState extends State<QuestionCheckmark> {
  void _validateAnswer(Student student, Answer answer) {
    // Reverse the status of the answer
    final newAnswer = answer.copyWith(
        isValidated: !answer.isValidated, actionRequired: ActionRequired.none);
    student.allAnswers[widget.question] = newAnswer;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.studentId == null) return Container();

    final students = Provider.of<AllStudents>(context, listen: false);
    final student =
        widget.studentId == null ? null : students[widget.studentId];
    final answer = student == null ? null : student.allAnswers[widget.question];
    return answer != null
        ? IconButton(
            onPressed: () => _validateAnswer(student!, answer),
            icon: Icon(
              Icons.check,
              color: answer.isValidated ? Colors.green[600] : Colors.grey[300],
            ))
        : Container();
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
          if (isActive && studentId != null) const SizedBox(height: 12),
          if (isActive && studentId != null) DiscussionListView(answer: answer),
          const SizedBox(height: 15)
        ],
      ),
    );
  }
}

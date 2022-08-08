import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './discussion_list_view.dart';
import '../../../common/models/answer.dart';
import '../../../common/models/enum.dart';
import '../../../common/models/question.dart';
import '../../../common/models/student.dart';
import '../../../common/providers/all_students.dart';
import '../../../common/widgets/are_you_sure_dialog.dart';
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

  late final AllStudents _students;
  late final Student? _student;
  Answer? _answer;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();

    _students = Provider.of<AllStudents>(context, listen: false);
    _student = widget.studentId != null ? _students[widget.studentId] : null;
    _answer = _student?.allAnswers[widget.question];
    _isActive = _answer != null
        ? _answer!.isActive
        : _students.indexWhere(
              (s) {
                final answer = s.allAnswers[widget.question];
                return answer == null ? false : !answer.isActive;
              },
            ) <
            0;
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
      number: answer?.action == ActionRequired.fromTeacher ? 0 : null,
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
              trailing: widget.studentId == null
                  ? QuestionActivatedState(
                      question: widget.question,
                      studentId: widget.studentId,
                      initialStatus: _isActive,
                      onStateChange: onStateChange,
                    )
                  : QuestionValidateCheckmark(
                      question: widget.question,
                      studentId: widget.studentId!,
                    ),
              onTap: widget.studentId == null ? null : _expand,
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

class QuestionActivatedState extends StatefulWidget {
  const QuestionActivatedState(
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
  State<QuestionActivatedState> createState() => _QuestionActivator();
}

class _QuestionActivator extends State<QuestionActivatedState> {
  var _isActive = false;

  @override
  void initState() {
    super.initState();
    _isActive = widget.initialStatus;
  }

  Future<void> _toggleQuestionActiveState(value) async {
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
          student.allAnswers[widget.question]!.copyWith(isActive: _isActive);
    } else {
      for (var student in students) {
        student.allAnswers[widget.question] =
            student.allAnswers[widget.question]!.copyWith(isActive: _isActive);
      }
    }
    widget.onStateChange(() {});
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Switch(onChanged: _toggleQuestionActiveState, value: _isActive);
  }
}

class QuestionValidateCheckmark extends StatefulWidget {
  const QuestionValidateCheckmark({
    Key? key,
    required this.question,
    required this.studentId,
  }) : super(key: key);

  final Question question;
  final String studentId;

  @override
  State<QuestionValidateCheckmark> createState() =>
      _QuestionValidateCheckmarkState();
}

class _QuestionValidateCheckmarkState extends State<QuestionValidateCheckmark> {
  void _validateAnswer(Student student, Answer answer) {
    // Reverse the status of the answer
    final newAnswer = answer.copyWith(
        isValidated: !answer.isValidated, actionRequired: ActionRequired.none);
    student.allAnswers[widget.question] = newAnswer;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final students = Provider.of<AllStudents>(context, listen: false);
    final student = students[widget.studentId];
    final answer = student.allAnswers[widget.question]!;
    return IconButton(
        onPressed: () => _validateAnswer(student, answer),
        icon: Icon(
          Icons.check,
          color: answer.isValidated ? Colors.green[600] : Colors.grey[300],
        ));
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
    final student = students[studentId];
    final answer = student.allAnswers[question]!;

    return Container(
      padding: const EdgeInsets.only(left: 40, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (answer.isActive && studentId != null)
            DiscussionListView(answer: answer),
          const SizedBox(height: 15)
        ],
      ),
    );
  }
}

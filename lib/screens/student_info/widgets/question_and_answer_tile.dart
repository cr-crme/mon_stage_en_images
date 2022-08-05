import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './discussion_list_view.dart';
import '../../../common/models/answer.dart';
import '../../../common/models/enum.dart';
import '../../../common/models/question.dart';
import '../../../common/models/student.dart';
import '../../../common/providers/all_students.dart';
import '../../../common/providers/login_information.dart';
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
    if (answer != null && answer.action != ActionRequired.none) {
      // Flag the answer as being actionned
      _student!.allAnswers[widget.question] =
          answer.copyWith(action: ActionRequired.none);
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
        isValidated: !answer.isValidated, action: ActionRequired.none);
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
    final userIsStudent =
        Provider.of<LoginInformation>(context, listen: false).loginType ==
            LoginType.student;
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
          if (isActive && studentId != null) _showPhoto(userIsStudent, answer),
          if (isActive && studentId != null) const SizedBox(height: 12),
          if (isActive && studentId != null) DiscussionListView(answer: answer),
          if (userIsStudent) const SizedBox(height: 15),
          if (!userIsStudent)
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

  Widget _showPhoto(bool userIsStudent, answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Photo : ', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        // TODO: Add the logic to take a picture when user is a student
        answer!.photoUrl == null
            ? (userIsStudent
                ? const Center(
                    child: ElevatedButton(
                        onPressed: null, child: Text('Prendre une photo')),
                  )
                : const Center(
                    child: Text('En attente de la photo de l\'étudiant',
                        style: TextStyle(color: Colors.red))))
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
        Switch(onChanged: _toggleQuestionActiveState, value: _isActive),
      ],
    );
  }
}

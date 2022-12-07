import 'package:defi_photo/common/models/text_reader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/answer.dart';
import '/common/models/enum.dart';
import '/common/models/question.dart';
import '/common/models/student.dart';
import '/common/providers/all_questions.dart';
import '/common/providers/all_students.dart';
import '/screens/q_and_a/widgets/new_question_alert_dialog.dart';
import 'answer_tile_part.dart';
import 'question_tile_part.dart';

class QuestionAndAnswerTile extends StatefulWidget {
  const QuestionAndAnswerTile(
    this.question, {
    super.key,
    required this.studentId,
    required this.sectionIndex,
    required this.questionView,
  });

  final int sectionIndex;
  final String? studentId;
  final Question? question;
  final QuestionView questionView;

  @override
  State<QuestionAndAnswerTile> createState() => _QuestionAndAnswerTileState();
}

class _QuestionAndAnswerTileState extends State<QuestionAndAnswerTile> {
  var _isExpanded = false;

  late AllStudents _students;
  Student? _student;
  Answer? _answer;
  final _reader = TextReader();
  bool _isReading = false;

  @override
  void dispose() {
    super.dispose();
    _reader.stopReading();
  }

  void _expand() {
    _isExpanded = !_isExpanded;

    final answer = _answer;
    if (answer != null &&
        answer.action(context) == ActionRequired.fromTeacher) {
      // Flag the answer as being actionned
      _students.setAnswer(
          student: _student!,
          question: widget.question!,
          answer: answer.copyWith(actionRequired: ActionRequired.none));
    }
    _answer = _student!.allAnswers[widget.question];

    setState(() {});
  }

  Future<void> _addOrModifyQuestion() async {
    final questions = Provider.of<AllQuestions>(context, listen: false);

    // Make sure no student already responded to the question
    // If so, prevent from modifying it
    var hasAnswers = false;
    if (widget.question != null) {
      for (final student in _students) {
        if (student.allAnswers[widget.question!]!.hasAnswer) {
          hasAnswers = true;
          break;
        }
      }
    }

    if (hasAnswers) {
      await showDialog(
        context: context,
        builder: (BuildContext context) => const AlertDialog(
          content: Text(
            'Il n\'est pas possible de modifier le libellé d\'une question '
            'si au moins un élève a déjà répondu',
          ),
        ),
      );
      return;
    }

    final currentStudent =
        ModalRoute.of(context)!.settings.arguments as Student?;

    final question = await showDialog<Question>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) => NewQuestionAlertDialog(
        section: widget.sectionIndex,
        student: currentStudent,
        title: widget.question?.text,
        deleteCallback: widget.questionView == QuestionView.modifyForAllStudents
            ? _deleteQuestionCallback
            : null,
      ),
    );
    if (question == null) return;

    if (widget.question != null) {
      var newQuestion = widget.question!.copyWith(text: question.text);
      questions.modifyToAll(newQuestion,
          students: _students, currentStudent: currentStudent);
    } else {
      questions.addToAll(question,
          students: _students, currentStudent: currentStudent);
    }
    setState(() {});
  }

  void _deleteQuestionCallback() {
    final questions = Provider.of<AllQuestions>(context, listen: false);
    questions.removeToAll(widget.question!, students: _students);
    setState(() {});
  }

  void _onStateChange(VoidCallback fn) {
    if (_student != null) {
      _answer = _student!.allAnswers[widget.question];
    }
    fn();
    setState(() {});
  }

  void _startReading() {
    if (widget.question == null) return;

    _isReading = true;
    _reader.read(widget.question!, _isExpanded ? _answer : null,
        hasFinishedCallback: _stopReading);
    setState(() {});
  }

  void _stopReading() {
    _reader.stopReading();
    _isReading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _students = Provider.of<AllStudents>(context, listen: true);
    _student = widget.studentId != null ? _students[widget.studentId] : null;
    _answer =
        widget.question != null ? _student?.allAnswers[widget.question] : null;

    return Card(
      elevation: 5,
      child: Column(
        children: [
          QuestionPart(
            question: widget.question,
            questionView: widget.questionView,
            studentId: widget.studentId,
            answer: _answer,
            onStateChange: _onStateChange,
            onTap: widget.questionView == QuestionView.normal
                ? _expand
                : _addOrModifyQuestion,
            onChangeQuestionRequest: _addOrModifyQuestion,
            isAnswerShown: _isExpanded,
            isReading: _isReading,
            startReadingCallback: _startReading,
            stopReadingCallback: _stopReading,
          ),
          if (_isExpanded && widget.questionView == QuestionView.normal)
            AnswerPart(
              widget.question!,
              onStateChange: _onStateChange,
              studentId: widget.studentId,
            ),
        ],
      ),
    );
  }
}

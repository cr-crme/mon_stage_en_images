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
    required this.viewSpan,
    required this.pageMode,
  });

  final int sectionIndex;
  final String? studentId;
  final Question? question;
  final Target viewSpan;
  final PageMode pageMode;

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
    final arguments = ModalRoute.of(context)!.settings.arguments as List;

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

    final currentStudent = arguments[2] as Student?;

    final output = await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) => NewQuestionAlertDialog(
        section: widget.sectionIndex,
        student: currentStudent,
        question: widget.question,
        isQuestionModifiable: !hasAnswers,
        deleteCallback:
            widget.pageMode == PageMode.edit ? _deleteQuestionCallback : null,
      ),
    );
    if (output == null) return;
    final question = output[0] as Question;
    final activeStatus = output[1] as Map<Student, bool>;

    if (widget.question != null) {
      var newQuestion = widget.question!.copyWith(text: question.text);
      questions.modifyToAll(newQuestion,
          students: _students,
          currentStudent: currentStudent,
          isActive: activeStatus);
    } else {
      questions.addToAll(question,
          students: _students,
          currentStudent: currentStudent,
          isActive: activeStatus);
    }

    setState(() {});
  }

  void _deleteQuestionCallback() {
    final questions = Provider.of<AllQuestions>(context, listen: false);
    questions.removeToAll(widget.question!, students: _students);
    setState(() {});
  }

  void _onStateChange() {
    if (_student != null) {
      _answer = _student!.allAnswers[widget.question];
    }
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
            viewSpan: widget.viewSpan,
            pageMode: widget.pageMode,
            studentId: widget.studentId,
            answer: _answer,
            onStateChange: _onStateChange,
            onTap: widget.viewSpan == Target.individual &&
                    widget.pageMode != PageMode.edit
                ? _expand
                : _addOrModifyQuestion,
            isAnswerShown: _isExpanded && widget.pageMode != PageMode.edit,
            isReading: _isReading,
            startReadingCallback: _startReading,
            stopReadingCallback: _stopReading,
          ),
          if (_isExpanded &&
              widget.viewSpan == Target.individual &&
              widget.pageMode != PageMode.edit)
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

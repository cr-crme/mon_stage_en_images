import 'package:defi_photo/common/models/answer.dart';
import 'package:defi_photo/common/models/answer_sort_and_filter.dart';
import 'package:defi_photo/common/models/database.dart';
import 'package:defi_photo/common/models/enum.dart';
import 'package:defi_photo/common/models/question.dart';
import 'package:defi_photo/common/models/text_reader.dart';
import 'package:defi_photo/common/models/user.dart';
import 'package:defi_photo/common/providers/all_answers.dart';
import 'package:defi_photo/common/providers/all_questions.dart';
import 'package:defi_photo/screens/q_and_a/widgets/answer_tile_part.dart';
import 'package:defi_photo/screens/q_and_a/widgets/new_question_alert_dialog.dart';
import 'package:defi_photo/screens/q_and_a/widgets/question_tile_part.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuestionAndAnswerTile extends StatefulWidget {
  const QuestionAndAnswerTile(
    this.question, {
    super.key,
    required this.studentId,
    required this.sectionIndex,
    required this.viewSpan,
    required this.pageMode,
    required this.answerFilterMode,
    this.overrideExpandState,
    this.onExpand,
  });

  final int sectionIndex;
  final String? studentId;
  final Question? question;
  final Target viewSpan;
  final PageMode pageMode;
  final AnswerSortAndFilter? answerFilterMode;
  final bool? overrideExpandState;
  final VoidCallback? onExpand;

  @override
  State<QuestionAndAnswerTile> createState() => _QuestionAndAnswerTileState();
}

class _QuestionAndAnswerTileState extends State<QuestionAndAnswerTile> {
  var _isExpanded = false;

  Answer? get _answer {
    if (widget.question == null || widget.studentId == null) return null;

    final answers = Provider.of<AllAnswers>(context, listen: false).filter(
        questionIds: [widget.question!.id], studentIds: [widget.studentId!]);
    return answers.isEmpty ? null : answers.first;
  }

  final _reader = TextReader();
  bool _isReading = false;

  @override
  void dispose() {
    _reader.stopReading();
    super.dispose();
  }

  void _expand() {
    _isExpanded = !_isExpanded;

    // If not in see all answers agregated view mode
    if (widget.pageMode != PageMode.fixView) {
      // If teacher has something to do, looking at the question is sufficient
      final teacherMadeAction =
          _answer!.action(context) == ActionRequired.fromTeacher;

      // If student has something to do, if the question is validaded,
      // looking a the question is sufficient
      final studentMadeAction =
          _answer!.action(context) == ActionRequired.fromStudent &&
              _answer!.isValidated;

      if (_isExpanded &&
          widget.studentId != null &&
          (teacherMadeAction || studentMadeAction)) {
        // Flag the answer as being actionned
        Provider.of<AllAnswers>(context, listen: false)
            .addAnswer(_answer!.copyWith(actionRequired: ActionRequired.none));
      }
    }
    if (widget.onExpand != null) widget.onExpand!();

    setState(() {});
  }

  Future<void> _addOrModifyQuestion() async {
    final answers = Provider.of<AllAnswers>(context, listen: false);
    final questions = Provider.of<AllQuestions>(context, listen: false);
    final db = Provider.of<Database>(context, listen: false);
    final arguments = ModalRoute.of(context)!.settings.arguments as List;

    // Make sure no student already responded to the question
    // If so, prevent from modifying it
    final hasAnswers = widget.question != null
        ? questions[widget.question].hasAtLeastOneAnswer(answers: answers)
        : false;

    final currentStudent = arguments[2] as User?;

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
    final activeStatus = output[1] as Map<String, bool>;

    if (widget.question == null) {
      questions.addToAll(question,
          answers: answers,
          currentUser: db.currentUser!,
          isActive: activeStatus);
    } else {
      questions.modifyToAll(
        widget.question!.copyWith(text: question.text),
        studentAnswers: answers,
        currentUser: db.currentUser!,
        isActive: activeStatus,
      );
    }

    setState(() {});
  }

  void _deleteQuestionCallback() {
    final questions = Provider.of<AllQuestions>(context, listen: false);
    final answers = Provider.of<AllAnswers>(context, listen: false);

    questions.removeToAll(widget.question!, answers: answers);
    setState(() {});
  }

  void _onStateChange() => setState(() {});

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
    _isExpanded = widget.overrideExpandState ?? _isExpanded;
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
            onTap: widget.pageMode == PageMode.edit
                ? _addOrModifyQuestion
                : _expand,
            isAnswerShown: _isExpanded && widget.pageMode != PageMode.edit,
            isReading: _isReading,
            startReadingCallback: _startReading,
            stopReadingCallback: _stopReading,
          ),
          if (_isExpanded && widget.pageMode != PageMode.edit)
            AnswerPart(
              widget.question!,
              onStateChange: _onStateChange,
              studentId: widget.studentId,
              pageMode: widget.pageMode,
              filterMode: widget.answerFilterMode,
            ),
        ],
      ),
    );
  }
}

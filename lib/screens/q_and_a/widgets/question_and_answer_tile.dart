import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './question_tile_part.dart';
import './answer_tile_part.dart';
import '../../q_and_a/widgets/new_question_alert_dialog.dart';
import '../../../common/models/answer.dart';
import '../../../common/models/enum.dart';
import '../../../common/models/question.dart';
import '../../../common/models/student.dart';
import '../../../common/providers/all_questions.dart';
import '../../../common/providers/all_students.dart';
import '../../../common/providers/login_information.dart';
import '../../../common/widgets/taking_action_notifier.dart';

class QuestionAndAnswerTile extends StatefulWidget {
  const QuestionAndAnswerTile(
    this.question, {
    Key? key,
    required this.studentId,
    required this.sectionIndex,
    required this.questionView,
  }) : super(key: key);

  final int sectionIndex;
  final String? studentId;
  final Question? question;
  final QuestionView questionView;

  @override
  State<QuestionAndAnswerTile> createState() => _QuestionAndAnswerTileState();
}

class _QuestionAndAnswerTileState extends State<QuestionAndAnswerTile> {
  var _isExpanded = false;

  late final LoginInformation _loginInfo;
  late final AllStudents _students;
  late final Student? _student;
  Answer? _answer;

  @override
  void initState() {
    super.initState();

    _loginInfo = Provider.of<LoginInformation>(context, listen: false);
    _students = Provider.of<AllStudents>(context, listen: false);
    _student = widget.studentId != null ? _students[widget.studentId] : null;
    _answer = _student?.allAnswers[widget.question];
  }

  void _expand() {
    _isExpanded = !_isExpanded;

    final answer = _answer;
    if (answer != null &&
        answer.action(context) == ActionRequired.fromTeacher) {
      // Flag the answer as being actionned
      _student!.allAnswers[widget.question] =
          answer.copyWith(actionRequired: ActionRequired.none);
    }
    _answer = _student!.allAnswers[widget.question];

    setState(() {});
  }

  Future<void> _addOrModifyQuestion() async {
    final questions = Provider.of<AllQuestions>(context, listen: false);
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

    if (widget.question == null) {
      questions.addToAll(question,
          students: _students, currentStudent: currentStudent);
    } else {
      var newQuestion = widget.question!.copyWith(text: question.text);
      questions.modifyToAll(newQuestion,
          students: _students, currentStudent: currentStudent);
    }
    setState(() {});
  }

  void _deleteQuestionCallback() {
    final questions = Provider.of<AllQuestions>(context, listen: false);
    final students = Provider.of<AllStudents>(context, listen: false);
    questions.removeToAll(widget.question!, students: students);
    setState(() {});
  }

  void _onStateChange(VoidCallback fn) {
    _answer = _student!.allAnswers[widget.question];
    fn();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasAction = (_answer?.action(context) ?? ActionRequired.none) !=
        ActionRequired.none;
    return TakingActionNotifier(
      number: _loginInfo.loginType == LoginType.teacher && hasAction ? 0 : null,
      left: 10,
      child: Card(
        elevation: 5,
        child: Column(
          children: [
            QuestionPart(
              context,
              question: widget.question,
              questionView: widget.questionView,
              studentId: widget.studentId,
              answer: _answer,
              onStateChange: _onStateChange,
              onTap: widget.questionView == QuestionView.normal
                  ? _expand
                  : _addOrModifyQuestion,
              onChangeQuestionRequest: _addOrModifyQuestion,
            ),
            if (_isExpanded && widget.questionView == QuestionView.normal)
              AnswerPart(
                widget.question!,
                onStateChange: _onStateChange,
                studentId: widget.studentId,
              ),
          ],
        ),
      ),
    );
  }
}

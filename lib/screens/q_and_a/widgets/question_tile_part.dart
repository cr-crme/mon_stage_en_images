import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/answer.dart';
import '/common/models/database.dart';
import '/common/models/enum.dart';
import '/common/models/exceptions.dart';
import '/common/models/question.dart';
import '/common/models/student.dart';
import '/common/providers/all_questions.dart';
import '/common/providers/all_students.dart';
import '/common/widgets/are_you_sure_dialog.dart';
import '/common/widgets/taking_action_notifier.dart';

class QuestionPart extends StatelessWidget {
  const QuestionPart({
    super.key,
    required this.question,
    required this.questionView,
    required this.studentId,
    required this.answer,
    required this.isAnswerShown,
    required this.onTap,
    required this.onStateChange,
    required this.isReading,
    required this.startReadingCallback,
    required this.stopReadingCallback,
  });

  final Question? question;
  final QuestionView questionView;
  final String? studentId;
  final Answer? answer;
  final bool isAnswerShown;
  final VoidCallback onTap;
  final VoidCallback onStateChange;
  final bool isReading;
  final VoidCallback startReadingCallback;
  final VoidCallback stopReadingCallback;

  TextStyle _pickTextStyle(BuildContext context, Answer? answer) {
    if (answer == null) {
      return const TextStyle();
    }
    final userType =
        Provider.of<Database>(context, listen: false).currentUser!.userType;

    return TextStyle(
      color: userType == UserType.student ||
              answer.isAnswered ||
              answer.isValidated
          ? Colors.black
          : answer.isActive
              ? Colors.red
              : Colors.grey,
      fontWeight: answer.action(context) != ActionRequired.none
          ? userType == UserType.teacher
              ? FontWeight.w900
              : FontWeight.bold
          : FontWeight.normal,
      fontSize: userType == UserType.student ? 20 : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(question == null ? 'Nouvelle question' : question!.text,
          style: _pickTextStyle(context, answer)),
      trailing: _QuestionPartTrailing(
        question: question,
        onNewQuestion: onTap,
        questionView: questionView,
        studentId: studentId,
        onStateChange: onStateChange,
        hasAction: (answer?.action(context) ?? ActionRequired.none) !=
            ActionRequired.none,
        isAnswerShown: isAnswerShown,
        isReading: isReading,
        startReadingCallback: startReadingCallback,
        stopReadingCallback: stopReadingCallback,
      ),
      onTap: onTap,
    );
  }
}

class _QuestionPartTrailing extends StatelessWidget {
  const _QuestionPartTrailing({
    required this.question,
    required this.onNewQuestion,
    required this.questionView,
    required this.studentId,
    required this.onStateChange,
    required this.hasAction,
    required this.isAnswerShown,
    required this.isReading,
    required this.startReadingCallback,
    required this.stopReadingCallback,
  });

  final Question? question;
  final VoidCallback onNewQuestion;
  final QuestionView questionView;
  final String? studentId;
  final VoidCallback onStateChange;
  final bool hasAction;
  final bool isAnswerShown;
  final bool isReading;
  final VoidCallback startReadingCallback;
  final VoidCallback stopReadingCallback;

  bool _isQuestionActive(BuildContext context) {
    final students = Provider.of<AllStudents>(context, listen: false);
    final answer =
        studentId != null ? students[studentId].allAnswers[question] : null;

    if (students.count == 0) {
      return question != null && question?.defaultTarget == Target.all;
    }

    return questionView == QuestionView.modifyForAllStudents
        ? question != null
            ? students.isQuestionActiveForAll(question!)
            : false
        : answer == null
            ? false
            : answer.isActive;
  }

  @override
  Widget build(BuildContext context) {
    final userType =
        Provider.of<Database>(context, listen: false).currentUser!.userType;

    if (userType == UserType.student) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TakingActionNotifier(
            number: hasAction ? 1 : null,
            forcedText: '?',
            borderColor: Colors.black,
            child: const Text(''),
          ),
          isReading
              ? IconButton(
                  onPressed: stopReadingCallback,
                  icon: const Icon(Icons.volume_off))
              : IconButton(
                  onPressed: startReadingCallback,
                  icon: const Icon(Icons.volume_up)),
        ],
      );
    } else if (userType == UserType.teacher) {
      return question == null
          ? _QuestionAddButton(newQuestionCallback: onNewQuestion)
          : questionView == QuestionView.normal
              ? _QuestionValidateCheckmark(
                  question: question!, studentId: studentId!)
              : questionView == QuestionView.modifyForAllStudents
                  ? Container(width: 0)
                  : _QuestionActivatedState(
                      question: question!,
                      studentId: studentId,
                      initialStatus: _isQuestionActive(context),
                      onStateChange: onStateChange,
                      questionView: questionView,
                    );
    } else {
      throw const NotLoggedIn();
    }
  }
}

class _QuestionAddButton extends StatelessWidget {
  const _QuestionAddButton({required this.newQuestionCallback});
  final VoidCallback newQuestionCallback;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: newQuestionCallback,
        icon: Icon(
          Icons.add_circle,
          color: Theme.of(context).colorScheme.primary,
        ));
  }
}

class _QuestionActivatedState extends StatefulWidget {
  const _QuestionActivatedState({
    required this.studentId,
    required this.onStateChange,
    required this.initialStatus,
    required this.question,
    required this.questionView,
  });

  final String? studentId;
  final Question question;
  final bool initialStatus;
  final VoidCallback onStateChange;
  final QuestionView questionView;

  @override
  State<_QuestionActivatedState> createState() => _QuestionActivator();
}

class _QuestionActivator extends State<_QuestionActivatedState> {
  var _isActive = false;

  @override
  void initState() {
    super.initState();
    _isActive = widget.initialStatus;
  }

  Future<void> _toggleQuestionActiveState(value) async {
    final questions = Provider.of<AllQuestions>(context, listen: false);
    final students = Provider.of<AllStudents>(context, listen: false);
    final student =
        widget.studentId == null ? null : students[widget.studentId];

    final sure = widget.questionView == QuestionView.modifyForAllStudents
        ? await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AreYouSureDialog(
                title: 'Confimer le choix',
                content:
                    'Voulez-vous vraiment ${value ? 'activer' : 'désactiver'} '
                    'cette question pour tous les élèves ?',
              );
            },
          )
        : true;

    if (!sure!) return;

    _isActive = value;

    // Modify the question on the server.
    // If the default target ever was 'all' keep it like that, unless it is
    // deactivate for all. If it was 'individual' keep it like that unless it
    // should be promoted to 'all'
    late final Target newTarget;
    if (student == null) {
      newTarget = _isActive ? Target.all : Target.none;
    } else {
      newTarget = widget.question.defaultTarget;
    }
    questions.replace(widget.question.copyWith(defaultTarget: newTarget));

    // Modify the answers on the server
    if (student != null) {
      students.setAnswer(
          student: student,
          question: widget.question,
          answer: student.allAnswers[widget.question]!
              .copyWith(isActive: _isActive));
    } else {
      for (var student in students) {
        students.setAnswer(
            student: student,
            question: widget.question,
            answer: student.allAnswers[widget.question]!
                .copyWith(isActive: _isActive));
      }
    }
    widget.onStateChange();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Switch(onChanged: _toggleQuestionActiveState, value: _isActive);
  }
}

class _QuestionValidateCheckmark extends StatefulWidget {
  const _QuestionValidateCheckmark({
    required this.question,
    required this.studentId,
  });

  final Question question;
  final String studentId;

  @override
  State<_QuestionValidateCheckmark> createState() =>
      _QuestionValidateCheckmarkState();
}

class _QuestionValidateCheckmarkState
    extends State<_QuestionValidateCheckmark> {
  void _validateAnswer(Student student, Answer answer) {
    // Reverse the status of the answer
    final allStudents = Provider.of<AllStudents>(context, listen: false);

    final isValided = !answer.isValidated;
    final actionRequired =
        isValided ? ActionRequired.none : answer.previousActionRequired;
    allStudents.setAnswer(
        student: student,
        question: widget.question,
        answer: answer.copyWith(
            isValidated: isValided, actionRequired: actionRequired));
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
          size: 35,
          color: answer.isValidated ? Colors.green[600] : Colors.grey[350],
        ));
  }
}

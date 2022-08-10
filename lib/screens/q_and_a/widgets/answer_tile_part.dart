import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './discussion_list_view.dart';
import '../../../common/models/enum.dart';
import '../../../common/models/exceptions.dart';
import '../../../common/models/message.dart';
import '../../../common/models/question.dart';
import '../../../common/providers/all_students.dart';
import '../../../common/providers/login_information.dart';

class AnswerPart extends StatefulWidget {
  const AnswerPart(
    this.question, {
    Key? key,
    required this.studentId,
    required this.onStateChange,
  }) : super(key: key);

  final String? studentId;
  final Function(VoidCallback) onStateChange;
  final Question question;

  @override
  State<AnswerPart> createState() => _AnswerPartState();
}

class _AnswerPartState extends State<AnswerPart> {
  void _addAnswerCallback(String answerText, {bool isPhoto = false}) {
    final loginInfo = Provider.of<LoginInformation>(context, listen: false);
    final students = Provider.of<AllStudents>(context, listen: false);
    final student =
        widget.studentId != null ? students[widget.studentId] : null;

    final currentAnswer = student!.allAnswers[widget.question]!;

    currentAnswer.addToDiscussion(Message(
      name: loginInfo.user!.name,
      text: answerText,
      isPhotoUrl: isPhoto,
    ));

    // Inform the changing of status
    late final ActionRequired newStatus;
    if (loginInfo.loginType == LoginType.student) {
      newStatus = ActionRequired.fromTeacher;
    } else if (loginInfo.loginType == LoginType.teacher) {
      newStatus = ActionRequired.fromStudent;
    } else {
      throw const NotLoggedIn();
    }
    student.allAnswers[widget.question] =
        currentAnswer.copyWith(text: answerText, actionRequired: newStatus);

    widget.onStateChange(() {});
  }

  @override
  Widget build(BuildContext context) {
    final students = Provider.of<AllStudents>(context, listen: false);
    final student = students[widget.studentId];
    final answer = student.allAnswers[widget.question]!;

    return Container(
      padding: const EdgeInsets.only(left: 40, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (answer.isActive && widget.studentId != null)
            DiscussionListView(
                answer: answer, addMessageCallback: _addAnswerCallback),
          const SizedBox(height: 15)
        ],
      ),
    );
  }
}

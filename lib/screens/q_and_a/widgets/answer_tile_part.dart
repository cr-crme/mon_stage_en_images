import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/database.dart';
import '/common/models/enum.dart';
import '/common/models/exceptions.dart';
import '/common/models/message.dart';
import '/common/models/question.dart';
import '/common/providers/all_students.dart';
import 'discussion_list_view.dart';

class AnswerPart extends StatefulWidget {
  const AnswerPart(
    this.question, {
    super.key,
    required this.studentId,
    required this.onStateChange,
  });

  final String? studentId;
  final VoidCallback onStateChange;
  final Question question;

  @override
  State<AnswerPart> createState() => _AnswerPartState();
}

class _AnswerPartState extends State<AnswerPart> {
  Future<void> _addAnswerCallback(String answerText,
      {bool isPhoto = false}) async {
    final currentUser =
        Provider.of<Database>(context, listen: false).currentUser!;
    final students = Provider.of<AllStudents>(context, listen: false);
    final student =
        widget.studentId != null ? students[widget.studentId] : null;

    final currentAnswer = student!.allAnswers[widget.question]!;

    currentAnswer.addToDiscussion(Message(
      name: currentUser.firstName,
      text: answerText,
      isPhotoUrl: isPhoto,
      creatorId: currentUser.id,
    ));

    // Inform the changing of status
    late final ActionRequired newStatus;
    if (currentUser.userType == UserType.student) {
      newStatus = ActionRequired.fromTeacher;
    } else if (currentUser.userType == UserType.teacher) {
      newStatus = ActionRequired.fromStudent;
    } else {
      throw const NotLoggedIn();
    }
    students.setAnswer(
        student: student,
        question: widget.question,
        answer: currentAnswer.copyWith(actionRequired: newStatus));

    widget.onStateChange();
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
              answer: answer,
              student: student,
              addMessageCallback: _addAnswerCallback,
            ),
          const SizedBox(height: 15)
        ],
      ),
    );
  }
}

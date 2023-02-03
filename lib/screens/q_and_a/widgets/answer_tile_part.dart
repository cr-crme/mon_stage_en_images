import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/answer.dart';
import '/common/models/database.dart';
import '/common/models/discussion.dart';
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
    required this.pageMode,
  });

  final String? studentId;
  final VoidCallback onStateChange;
  final Question question;
  final PageMode pageMode;

  @override
  State<AnswerPart> createState() => _AnswerPartState();
}

class _AnswerPartState extends State<AnswerPart> {
  Answer _combineAnswersFromAllStudents(AllStudents students) {
    var discussionsNonSorted = Discussion();
    for (final student in students) {
      if (student.allAnswers[widget.question] == null) continue;
      for (final message in student.allAnswers[widget.question]!.discussion) {
        discussionsNonSorted.add(message);
      }
    }
    final discussionTimeSorted = Discussion.fromList(
        discussionsNonSorted.toList()
          ..sort((message1, message2) =>
              message2.creationTimeStamp - message1.creationTimeStamp));

    return Answer(discussion: discussionTimeSorted);
  }

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
    final student =
        widget.studentId != null ? students[widget.studentId] : null;

    final answer = student?.allAnswers[widget.question]! ??
        _combineAnswersFromAllStudents(students);

    return Container(
      padding: const EdgeInsets.only(left: 40, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.pageMode != PageMode.edit)
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

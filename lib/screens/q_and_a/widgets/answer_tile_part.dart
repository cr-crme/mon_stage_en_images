import 'package:defi_photo/common/models/answer.dart';
import 'package:defi_photo/common/models/answer_sort_and_filter.dart';
import 'package:defi_photo/common/models/database.dart';
import 'package:defi_photo/common/models/discussion.dart';
import 'package:defi_photo/common/models/enum.dart';
import 'package:defi_photo/common/models/exceptions.dart';
import 'package:defi_photo/common/models/message.dart';
import 'package:defi_photo/common/models/question.dart';
import 'package:defi_photo/common/providers/all_answers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'discussion_list_view.dart';

class AnswerPart extends StatefulWidget {
  const AnswerPart(
    this.question, {
    super.key,
    required this.studentId,
    required this.onStateChange,
    required this.pageMode,
    required this.filterMode,
  });

  final String? studentId;
  final VoidCallback onStateChange;
  final Question question;
  final PageMode pageMode;
  final AnswerSortAndFilter? filterMode;

  @override
  State<AnswerPart> createState() => _AnswerPartState();
}

class _AnswerPartState extends State<AnswerPart> {
  List<Message> _combineMessagesFromAllStudents(List<Answer> answers) {
    final teacherId =
        Provider.of<Database>(context, listen: false).currentUser!.id;

    // Fetch all the required answers
    var discussions = Discussion();

    final answer = answers.first;
    for (final message in answer.discussion.toListByTime(reversed: true)) {
      final isTheRightCreatorId = (widget.filterMode!.fromWhomFilter
                  .contains(AnswerFromWhomFilter.studentOnly) &&
              message.creatorId != teacherId) ||
          (widget.filterMode!.fromWhomFilter
                  .contains(AnswerFromWhomFilter.teacherOnly) &&
              message.creatorId == teacherId);

      final isTheRightContent = (widget.filterMode!.contentFilter
                  .contains(AnswerContentFilter.textOnly) &&
              !message.isPhotoUrl) ||
          (widget.filterMode!.contentFilter
                  .contains(AnswerContentFilter.photoOnly) &&
              message.isPhotoUrl);
      if (isTheRightCreatorId && isTheRightContent) {
        discussions.add(message);
      }
    }

    // Filter by date if required
    return widget.filterMode!.sorting == AnswerSorting.byDate
        ? discussions.toListByTime(reversed: true)
        : discussions.toList();
  }

  void _manageAnswerCallback({
    String? newTextEntry,
    bool? isPhoto,
    bool? markAsValidated,
  }) {
    final currentUser =
        Provider.of<Database>(context, listen: false).currentUser!;
    final allAnswers = Provider.of<AllAnswers>(context, listen: false);
    final currentAnswer = allAnswers.filter(
        questions: [widget.question], studentIds: [widget.studentId!]).first;

    if (newTextEntry != null) {
      currentAnswer.addToDiscussion(Message(
        name: currentUser.firstName,
        text: newTextEntry,
        isPhotoUrl: isPhoto ?? false,
        creatorId: currentUser.id,
      ));
    }

    // Inform the changing of status
    late final ActionRequired newStatus;
    if (currentUser.userType == UserType.student) {
      newStatus = ActionRequired.fromTeacher;
    } else if (currentUser.userType == UserType.teacher) {
      if (markAsValidated ?? false) {
        // If the teacher marked as valided but left a comment, the student
        // should be notified
        newStatus = newTextEntry == null
            ? ActionRequired.none
            : ActionRequired.fromStudent;
      } else {
        newStatus = ActionRequired.fromStudent;
      }
    } else {
      throw const NotLoggedIn();
    }

    allAnswers.addAnswer(currentAnswer.copyWith(
      actionRequired: newStatus,
      isValidated: markAsValidated,
    ));

    widget.onStateChange();
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.studentId == null
        ? null
        : Provider.of<Database>(context, listen: false)
            .myStudents
            .firstWhere((e) => e.id == widget.studentId);

    final answers = Provider.of<AllAnswers>(context, listen: false).filter(
        questions: [widget.question], studentIds: [widget.studentId!]).toList();

    final messages = answers.length == 1
        ? answers[0].discussion.toListByTime(reversed: true)
        : _combineMessagesFromAllStudents(answers);
    final isValidated = answers.length == 1 ? answers[0].isValidated : false;

    return Container(
      padding: const EdgeInsets.only(left: 40, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.pageMode != PageMode.edit)
            DiscussionListView(
              messages: messages,
              isAnswerValidated: isValidated,
              student: student,
              question: widget.question,
              manageAnswerCallback: _manageAnswerCallback,
            ),
          const SizedBox(height: 15)
        ],
      ),
    );
  }
}

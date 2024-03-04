import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/models/answer.dart';
import 'package:mon_stage_en_images/common/models/answer_sort_and_filter.dart';
import 'package:mon_stage_en_images/common/models/database.dart';
import 'package:mon_stage_en_images/common/models/discussion.dart';
import 'package:mon_stage_en_images/common/models/enum.dart';
import 'package:mon_stage_en_images/common/models/exceptions.dart';
import 'package:mon_stage_en_images/common/models/message.dart';
import 'package:mon_stage_en_images/common/models/question.dart';
import 'package:mon_stage_en_images/common/providers/all_answers.dart';
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
  late final _filterMode =
      widget.filterMode ?? AnswerSortAndFilter(sorting: AnswerSorting.byDate);

  List<Message> _combineMessagesFromAllStudents(List<Answer> answers) {
    final teacherId =
        Provider.of<Database>(context, listen: false).currentUser!.id;

    // Fetch all the required answers
    var discussions = Discussion();
    for (final answer in answers) {
      for (final message in answer.discussion.toListByTime(reversed: true)) {
        final isTheRightCreatorId = (_filterMode.fromWhomFilter
                    .contains(AnswerFromWhomFilter.studentOnly) &&
                message.creatorId != teacherId) ||
            (_filterMode.fromWhomFilter
                    .contains(AnswerFromWhomFilter.teacherOnly) &&
                message.creatorId == teacherId);

        final isTheRightContent =
            (_filterMode.contentFilter.contains(AnswerContentFilter.textOnly) &&
                    !message.isPhotoUrl) ||
                (_filterMode.contentFilter
                        .contains(AnswerContentFilter.photoOnly) &&
                    message.isPhotoUrl);
        if (isTheRightCreatorId && isTheRightContent) {
          discussions.add(message);
        }
      }
    }

    // Filter by date if required
    return _filterMode.sorting == AnswerSorting.byDate
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
        questionIds: [widget.question.id],
        studentIds: [widget.studentId!]).first;

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

    allAnswers.modifyAnswer(currentAnswer.copyWith(
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
            .students
            .firstWhere((e) => e.id == widget.studentId);

    final answers = Provider.of<AllAnswers>(context).filter(
        questionIds: [widget.question.id],
        studentIds:
            widget.studentId == null ? null : [widget.studentId!]).toList();

    final messages = _combineMessagesFromAllStudents(answers);
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

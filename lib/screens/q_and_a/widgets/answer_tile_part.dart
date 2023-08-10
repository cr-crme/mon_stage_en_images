import 'package:defi_photo/common/models/answer_sort_and_filter.dart';
import 'package:defi_photo/common/models/database.dart';
import 'package:defi_photo/common/models/discussion.dart';
import 'package:defi_photo/common/models/enum.dart';
import 'package:defi_photo/common/models/exceptions.dart';
import 'package:defi_photo/common/models/message.dart';
import 'package:defi_photo/common/models/question.dart';
import 'package:defi_photo/common/providers/all_students.dart';
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
  List<Message> _combineMessagesFromAllStudents(AllStudents students) {
    final teacherId =
        Provider.of<Database>(context, listen: false).currentUser!.id;

    final sortedStudents = students.toList()
      ..sort(
        (student1, student2) => student1.lastName
            .toLowerCase()
            .compareTo(student2.lastName.toLowerCase()),
      );

    // Fetch all the required answers
    var discussions = Discussion();
    for (final student in sortedStudents) {
      if (student.allAnswers[widget.question] == null) continue;
      for (final message in student.allAnswers[widget.question]!.discussion
          .toListByTime(reversed: true)) {
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
    final students = Provider.of<AllStudents>(context, listen: false);
    final student =
        widget.studentId != null ? students[widget.studentId] : null;

    final currentAnswer = student!.allAnswers[widget.question]!;

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
    students.setAnswer(
        student: student,
        question: widget.question,
        answer: currentAnswer.copyWith(
          actionRequired: newStatus,
          isValidated: markAsValidated,
        ));

    widget.onStateChange();
  }

  @override
  Widget build(BuildContext context) {
    final students = Provider.of<AllStudents>(context, listen: false);
    final student =
        widget.studentId != null ? students[widget.studentId] : null;

    final answers = student?.allAnswers[widget.question]!;
    final messages = answers?.discussion.toListByTime(reversed: true) ??
        _combineMessagesFromAllStudents(students);
    final isValidated = answers?.isValidated ?? false;

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

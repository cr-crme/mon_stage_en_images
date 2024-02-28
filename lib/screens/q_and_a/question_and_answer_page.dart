import 'package:defi_photo/common/models/answer_sort_and_filter.dart';
import 'package:defi_photo/common/models/database.dart';
import 'package:defi_photo/common/models/enum.dart';
import 'package:defi_photo/common/models/question.dart';
import 'package:defi_photo/common/models/section.dart';
import 'package:defi_photo/common/providers/all_questions.dart';
import 'package:defi_photo/common/providers/all_answers.dart';
import 'package:defi_photo/screens/q_and_a/widgets/question_and_answer_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuestionAndAnswerPage extends StatelessWidget {
  const QuestionAndAnswerPage(
    this.sectionIndex, {
    super.key,
    required this.studentId,
    required this.viewSpan,
    required this.pageMode,
    required this.answerFilterMode,
  });

  static const routeName = '/question-and-answer-page';
  final int sectionIndex;
  final String? studentId;
  final Target viewSpan;
  final PageMode pageMode;
  final AnswerSortAndFilter answerFilterMode;

  @override
  Widget build(BuildContext context) {
    final userType =
        Provider.of<Database>(context, listen: false).currentUser!.userType;

    final allAnswers = Provider.of<AllAnswers>(context, listen: false);
    var questions = Provider.of<AllQuestions>(context, listen: true)
        .fromSection(sectionIndex)
        .toList();

    late Widget questionSection;
    AnswerSortAndFilter? filter;
    switch (viewSpan) {
      case Target.individual:
        if (pageMode != PageMode.edit) {
          final answers = allAnswers.filter(
              questionIds: questions.map((e) => e.id),
              studentIds: [studentId!],
              isActive: true);
          questions = answers
              .map((e) => questions.firstWhere((q) => q.id == e.questionId))
              .toList();
        }
        filter = null;
        break;
      case Target.all:
      case Target.none:
        if (studentId != null) {
          // TODO is this used?
          final answers = allAnswers.filter(
              questionIds: questions.map((e) => e.id),
              studentIds: [studentId!]);
          questions = answers
              .map((e) => questions.firstWhere((q) => q.id == e.questionId))
              .toList();
        }

        // Do not filter for edit mode
        if (pageMode != PageMode.edit &&
            answerFilterMode.filled ==
                AnswerFilledFilter.withAtLeastOneAnswer) {
          final answers = allAnswers.filter(
              questionIds: questions.map((e) => e.id), hasAnswer: true);
          final questionsWithDuplicates = answers
              .map((e) => questions.firstWhere((q) => q.id == e.questionId))
              .toList();
          final questionIds = questionsWithDuplicates.map((e) => e.id).toSet();
          questions = questionIds
              .map((e) => questionsWithDuplicates.firstWhere((q) => q.id == e))
              .toList();
        }

        filter = answerFilterMode;
        break;
    }

    questions.sort(
        (first, second) => first.creationTimeStamp - second.creationTimeStamp);

    questionSection = _buildQuestionSection(
      context,
      questions: questions,
      titleIfNothing:
          'Aucune question${pageMode == PageMode.fixView ? ' répondue' : ''} dans cette section',
      answerFilterMode: filter,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (userType == UserType.teacher)
            Container(
              padding: const EdgeInsets.only(left: 5, top: 15),
              child: Text(
                  '${Section.name(sectionIndex)}${pageMode == PageMode.edit ? ' (Mode édition)' : ''}',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.black)),
            ),
          if (viewSpan != Target.individual) const SizedBox(height: 10),
          if (viewSpan != Target.individual && pageMode == PageMode.edit)
            QuestionAndAnswerTile(
              null,
              sectionIndex: sectionIndex,
              studentId: studentId,
              viewSpan: viewSpan,
              pageMode: pageMode,
              answerFilterMode: null,
            ),
          if (viewSpan != Target.individual &&
              questions.isNotEmpty &&
              studentId != null)
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [Text('Activé pour cet élève'), SizedBox(width: 25)],
            ),
          questionSection,
        ],
      ),
    );
  }

  Widget _buildQuestionSection(
    BuildContext context, {
    required List<Question> questions,
    required String titleIfNothing,
    required AnswerSortAndFilter? answerFilterMode,
  }) {
    return questions.isNotEmpty
        ? QAndAListView(
            questions.toList(growable: false),
            sectionIndex: sectionIndex,
            studentId: studentId,
            viewSpan: viewSpan,
            pageMode: pageMode,
            answerFilterMode: answerFilterMode,
          )
        : Container(
            padding: const EdgeInsets.only(top: 10, bottom: 30),
            child: Text(titleIfNothing),
          );
  }
}

class QAndAListView extends StatefulWidget {
  const QAndAListView(
    this.questions, {
    super.key,
    required this.sectionIndex,
    required this.studentId,
    required this.viewSpan,
    required this.pageMode,
    required this.answerFilterMode,
  });

  final List<Question> questions;
  final int sectionIndex;
  final String? studentId;
  final Target viewSpan;
  final PageMode pageMode;
  final AnswerSortAndFilter? answerFilterMode;

  @override
  State<QAndAListView> createState() => _QAndAListViewState();
}

class _QAndAListViewState extends State<QAndAListView> {
  final List<bool> _isExpanded = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isExpanded.clear();

    for (var i = 0; i < widget.questions.length; i++) {
      _isExpanded.add(false);
    }
  }

  void _onExpand(index) {
    // If we closed the card, just do it
    if (_isExpanded[index]) {
      _isExpanded[index] = false;
    } else {
      // Close all the cards except the expanded one
      for (var i = 0; i < widget.questions.length; i++) {
        _isExpanded[i] = i == index;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Do some sanity checks just in case
    if (_isExpanded.length != widget.questions.length) {
      for (var i = 0; i < widget.questions.length; i++) {
        _isExpanded.add(false);
      }
    }

    return ListView.builder(
      reverse: true,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) => QuestionAndAnswerTile(
        widget.questions[index],
        sectionIndex: widget.sectionIndex,
        studentId: widget.studentId,
        viewSpan: widget.viewSpan,
        pageMode: widget.pageMode,
        answerFilterMode: widget.answerFilterMode,
        overrideExpandState: _isExpanded[index],
        onExpand: () => _onExpand(index),
      ),
      itemCount: widget.questions.length,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mon_stage_en_images/common/models/answer_sort_and_filter.dart';
import 'package:mon_stage_en_images/common/models/enum.dart';
import 'package:mon_stage_en_images/common/models/question.dart';
import 'package:mon_stage_en_images/common/models/section.dart';
import 'package:mon_stage_en_images/common/providers/all_answers.dart';
import 'package:mon_stage_en_images/common/providers/all_questions.dart';
import 'package:mon_stage_en_images/common/providers/database.dart';
import 'package:mon_stage_en_images/default_onboarding_steps.dart';
import 'package:mon_stage_en_images/onboarding/onboarding.dart';
import 'package:mon_stage_en_images/screens/q_and_a/widgets/metier_info_card.dart';
import 'package:mon_stage_en_images/screens/q_and_a/widgets/question_and_answer_tile.dart';
import 'package:provider/provider.dart';

class QuestionAndAnswerPage extends StatefulWidget {
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
  State<QuestionAndAnswerPage> createState() => _QuestionAndAnswerPageState();
}

class _QuestionAndAnswerPageState extends State<QuestionAndAnswerPage> {
  bool showInfo = true;

  bool _onScroll(UserScrollNotification notif) {
    if (notif.direction == ScrollDirection.reverse) {
      setState(() {
        showInfo = false;
      });
    } else if (notif.direction == ScrollDirection.forward) {
      setState(() {
        showInfo = true;
      });
    }
    return showInfo;
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final userType = database.userType;

    final allAnswers = AllAnswers.of(context, listen: false);
    var questions = Provider.of<AllQuestions>(context, listen: true)
        .fromSection(widget.sectionIndex)
        .toList();
    AnswerSortAndFilter? filter;
    switch (widget.viewSpan) {
      case Target.individual:
        if (widget.pageMode != PageMode.edit) {
          final answers = allAnswers.filter(
              questionIds: questions.map((e) => e.id),
              studentIds: [widget.studentId!],
              isActive: true);
          questions = answers
              .map((e) => questions.firstWhere((q) => q.id == e.questionId))
              .toList();
        }
        filter = null;
        break;
      case Target.all:
      case Target.none:
        // Do not filter for edit mode
        if (widget.pageMode != PageMode.edit &&
            widget.answerFilterMode.filled ==
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

        filter = widget.answerFilterMode;
        break;
    }

    questions.sort(
        (first, second) => first.creationTimeStamp - second.creationTimeStamp);

    final questionSection = _buildQuestionSection(
      context,
      questions: questions,
      titleIfNothing:
          'Aucune question${widget.pageMode == PageMode.fixView ? ' répondue' : ''} dans cette section',
      answerFilterMode: filter,
    );

    return NotificationListener<UserScrollNotification>(
      onNotification: (notification) => _onScroll(notification),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (userType == UserType.teacher)
                  Container(
                    padding: const EdgeInsets.only(left: 5, top: 15),
                    child: Text(
                        '${Section.name(widget.sectionIndex)}${widget.pageMode == PageMode.edit ? ' (Mode édition)' : ''}',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Colors.black)),
                  ),
                if (widget.viewSpan != Target.individual)
                  const SizedBox(height: 10),
                if (widget.viewSpan != Target.individual &&
                    widget.pageMode == PageMode.edit)
                  OnboardingContainer(
                    onInitialize: (context) => OnboardingContexts
                        .instance['new_question_button'] = context,
                    child: QuestionAndAnswerTile(
                      null,
                      sectionIndex: widget.sectionIndex,
                      studentId: widget.studentId,
                      viewSpan: widget.viewSpan,
                      pageMode: widget.pageMode,
                      answerFilterMode: null,
                    ),
                  ),
                if (widget.viewSpan != Target.individual &&
                    questions.isNotEmpty &&
                    widget.studentId != null)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Activé pour cet élève'),
                      SizedBox(width: 25)
                    ],
                  ),
                Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.sizeOf(context).height / 4),
                  child: questionSection,
                ),
              ],
            ),
          ),
          if (userType == UserType.teacher && widget.pageMode == PageMode.edit)
            Positioned(
              bottom: MediaQuery.of(context).viewPadding.bottom + 32,
              right: MediaQuery.of(context).viewPadding.right + 32,
              child: AnimatedSlide(
                  duration: Durations.long1,
                  curve: Curves.easeInOut,
                  offset: Offset(showInfo ? 2 : 0, 0),
                  // TODO : extract addOrModifyQuestion logic from QuestionAndAnswerTile
                  child: QuestionAndAnswerTile(null,
                      isIconOnly: true,
                      studentId: widget.studentId,
                      sectionIndex: widget.sectionIndex,
                      viewSpan: widget.viewSpan,
                      pageMode: widget.pageMode,
                      answerFilterMode: widget.answerFilterMode)),
            ),
          Positioned(
            bottom: MediaQuery.of(context).viewPadding.bottom,
            left: 0,
            right: 0,
            child: AnimatedSlide(
                duration: Durations.long1,
                curve: Curves.easeInOut,
                offset: Offset(0, showInfo ? 0 : 1.05),
                child: MetierInfoCard(sectionIndex: widget.sectionIndex)),
          )
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
            sectionIndex: widget.sectionIndex,
            studentId: widget.studentId,
            viewSpan: widget.viewSpan,
            pageMode: widget.pageMode,
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

  void _onExpand(int index) {
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

    return OnboardingContainer(
      onInitialize: (context) =>
          OnboardingContexts.instance['all_question_buttons'] = context,
      child: ListView.builder(
        reverse: true,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final child = QuestionAndAnswerTile(
            widget.questions[index],
            sectionIndex: widget.sectionIndex,
            studentId: widget.studentId,
            viewSpan: widget.viewSpan,
            pageMode: widget.pageMode,
            answerFilterMode: widget.answerFilterMode,
            overrideExpandState: _isExpanded[index],
            onExpand: () => _onExpand(index),
          );
          return child;
        },
        itemCount: widget.questions.length,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/models/answer_sort_and_filter.dart';
import 'package:mon_stage_en_images/common/models/database.dart';
import 'package:mon_stage_en_images/common/models/enum.dart';
import 'package:mon_stage_en_images/common/models/section.dart';
import 'package:mon_stage_en_images/common/models/user.dart';
import 'package:mon_stage_en_images/common/widgets/main_drawer.dart';
import 'package:mon_stage_en_images/onboarding/application/onboarding_observer.dart';
import 'package:mon_stage_en_images/screens/all_students/students_screen.dart';
import 'package:mon_stage_en_images/screens/q_and_a/main_metier_page.dart';
import 'package:mon_stage_en_images/screens/q_and_a/question_and_answer_page.dart';
import 'package:mon_stage_en_images/screens/q_and_a/widgets/filter_answers_dialog.dart';
import 'package:mon_stage_en_images/screens/q_and_a/widgets/metier_app_bar.dart';
import 'package:provider/provider.dart';

class QAndAScreen extends StatefulWidget {
  const QAndAScreen({
    super.key,
  });

  // static const routeName = '/q-and-a-screen';
  static const String routeName = '/q-and-a-screen';

  @override
  State<QAndAScreen> createState() => _QAndAScreenState();

  static void onPageChangedRequestFromOutside(
      State<QAndAScreen> outsideState, int int) {
    // debugPrint("context for onPageChangedRequestFromOutside is $context");
    // final state = context.findAncestorStateOfType<_QAndAScreenState>();
    final state = outsideState as _QAndAScreenState;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final controller = state._pageController;
      controller.animateToPage(int,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      // state.setState(() {});
    });
  }
}

class _QAndAScreenState extends State<QAndAScreen> {
  bool _isInitialized = false;
  UserType _userType = UserType.none;
  User? _student;
  Target _viewSpan = Target.individual;
  // late PageMode _pageMode;
  PageMode _pageMode = PageMode.fixView;
  var _answerFilter = AnswerSortAndFilter();
  VoidCallback? _pageViewAnimationListener;

  final _pageController = PageController();
  var _currentPage = 0;
  VoidCallback? _switchQuestionModeCallback;

  @override
  void initState() {
    _pageViewAnimationListener = () {
      debugPrint("page in pageControlller is ${_pageController.page}");
      if (_pageController.page == _pageController.page?.roundToDouble()) {
        OnboardingNavigatorObserver.instance.animationStatus.value =
            AnimationStatus.completed;
      } else {
        OnboardingNavigatorObserver.instance.animationStatus.value =
            AnimationStatus.dismissed;
      }
    };
    _pageController.addListener(_pageViewAnimationListener!);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInitialized) return;
    final database = Provider.of<Database>(context, listen: false);

    final currentUser = database.currentUser!;
    _userType = currentUser.userType;
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        final arguments = ModalRoute.of(context)!.settings.arguments as List;
        _viewSpan = arguments[0] as Target;
        setState(() {
          _pageMode = arguments[1] as PageMode;
        });
        _student =
            _userType == UserType.student ? currentUser : arguments[2] as User?;
      },
    );

    _isInitialized = true;
  }

  void onPageChanged(BuildContext context, int page) {
    _currentPage = page;
    // OnboardingNavigatorObserver.instance.animationStatus.value =
    //     AnimationStatus.forward;

    // On the main question page, if it is the teacher on a single student, then
    // back brings back to the student page. Otherwise, it opens the drawer.
    _switchQuestionModeCallback = page > 0 &&
            _userType == UserType.teacher &&
            _viewSpan == Target.individual
        ? () => _switchToQuestionManagerMode(context)
        : null;
    setState(() {});
  }

  void _filterAnswers() async {
    final answerFilter = await showDialog<AnswerSortAndFilter>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return FilterAnswerDialog(currentFilter: _answerFilter);
      },
    );
    if (answerFilter == null) return;

    _answerFilter = answerFilter;
    setState(() {});
  }

  void onPageChangedRequest(int page) {
    _pageController.animateToPage(page + 1,
        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
    setState(() {});
  }

  @override
  void dispose() {
    _pageController.removeListener(_pageViewAnimationListener!);
    _pageController.dispose();
    super.dispose();
  }

  void _onBackPressed() {
    if (_currentPage == 0) {
      // Replacement is used to force the redraw of the Notifier.
      // If the redrawing is ever fixed, this can be replaced by a pop.
      Navigator.of(context).pushReplacementNamed(StudentsScreen.routeName);
    }
    onPageChangedRequest(-1);
  }

  void _switchToQuestionManagerMode(BuildContext context) {
    if (_userType == UserType.student) return;
    if (_pageMode == PageMode.fixView) return;

    _pageMode =
        _pageMode == PageMode.edit ? PageMode.editableView : PageMode.edit;
    setState(() {});
  }

  AppBar _setAppBar() {
    final currentTheme = Theme.of(context).textTheme.titleLarge!;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_student?.toString() ??
              (_pageMode == PageMode.fixView
                  ? 'Résumé des réponses'
                  : 'Gestion des questions')),
          if (_userType == UserType.student)
            Text(
                _currentPage == 0
                    ? "Mon stage en images"
                    : Section.name(_currentPage - 1),
                style:
                    currentTheme.copyWith(fontSize: 15, color: onPrimaryColor)),
          if (_userType == UserType.teacher && _student != null)
            Text(
              _student!.companyNames,
              style: currentTheme.copyWith(fontSize: 15, color: onPrimaryColor),
            ),
        ],
      ),
      leading:
          _currentPage != 0 || _student != null && _userType == UserType.teacher
              ? BackButton(onPressed: _onBackPressed)
              : null,
      actions: _currentPage != 0 && _userType == UserType.teacher
          ? [
              if (_viewSpan == Target.individual)
                IconButton(
                  onPressed: _switchQuestionModeCallback,
                  icon: Icon(_pageMode == PageMode.edit
                      ? Icons.edit_off
                      : Icons.edit_rounded),
                  iconSize: 30,
                ),
              if (_viewSpan == Target.all && _pageMode == PageMode.fixView)
                IconButton(
                  onPressed: _filterAnswers,
                  icon: const Icon(Icons.filter_alt),
                  iconSize: 30,
                ),
              const SizedBox(width: 15),
            ]
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _setAppBar(),
      body: Column(
        children: [
          MetierAppBar(
            selected: _currentPage - 1,
            onPageChanged: onPageChangedRequest,
            studentId: _student?.id,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (value) => onPageChanged(context, value),
              children: [
                MainMetierPage(
                    student: _student, onPageChanged: onPageChangedRequest),
                QuestionAndAnswerPage(
                  0,
                  studentId: _student?.id,
                  viewSpan: _viewSpan,
                  pageMode: _pageMode,
                  answerFilterMode: _answerFilter,
                ),
                QuestionAndAnswerPage(
                  1,
                  studentId: _student?.id,
                  viewSpan: _viewSpan,
                  pageMode: _pageMode,
                  answerFilterMode: _answerFilter,
                ),
                QuestionAndAnswerPage(
                  2,
                  studentId: _student?.id,
                  viewSpan: _viewSpan,
                  pageMode: _pageMode,
                  answerFilterMode: _answerFilter,
                ),
                QuestionAndAnswerPage(
                  3,
                  studentId: _student?.id,
                  viewSpan: _viewSpan,
                  pageMode: _pageMode,
                  answerFilterMode: _answerFilter,
                ),
                QuestionAndAnswerPage(
                  4,
                  studentId: _student?.id,
                  viewSpan: _viewSpan,
                  pageMode: _pageMode,
                  answerFilterMode: _answerFilter,
                ),
                QuestionAndAnswerPage(
                  5,
                  studentId: _student?.id,
                  viewSpan: _viewSpan,
                  pageMode: _pageMode,
                  answerFilterMode: _answerFilter,
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: const MainDrawer(),
    );
  }
}

import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspath;

import './discussion_list_view.dart';
import '../../q_and_a/widgets/new_question_alert_dialog.dart';
import '../../../common/models/answer.dart';
import '../../../common/models/enum.dart';
import '../../../common/models/exceptions.dart';
import '../../../common/models/message.dart';
import '../../../common/models/question.dart';
import '../../../common/models/student.dart';
import '../../../common/providers/all_questions.dart';
import '../../../common/providers/all_students.dart';
import '../../../common/providers/login_information.dart';
import '../../../common/widgets/are_you_sure_dialog.dart';
import '../../../common/widgets/taking_action_notifier.dart';

class QuestionAndAnswerTile extends StatefulWidget {
  const QuestionAndAnswerTile(
    this.question, {
    Key? key,
    required this.studentId,
    required this.sectionIndex,
    required this.onStateChange,
    required this.questionView,
  }) : super(key: key);

  final int sectionIndex;
  final String? studentId;
  final Question? question;
  final Function(VoidCallback) onStateChange;
  final QuestionView questionView;

  @override
  State<QuestionAndAnswerTile> createState() => _QuestionAndAnswerTileState();
}

class _QuestionAndAnswerTileState extends State<QuestionAndAnswerTile> {
  var _isExpanded = false;

  late final LoginInformation _loginInfo;
  late final AllStudents _students;
  late final Student? _student;
  Answer? _answer;
  bool _isActive = false;

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    widget.onStateChange(() {});
  }

  @override
  void initState() {
    super.initState();

    _loginInfo = Provider.of<LoginInformation>(context, listen: false);
    _students = Provider.of<AllStudents>(context, listen: false);
    _student = widget.studentId != null ? _students[widget.studentId] : null;
    _answer = _student?.allAnswers[widget.question];
    _isActive = _answer != null
        ? _answer!.isActive
        : _students.indexWhere(
              (s) {
                final answer = s.allAnswers[widget.question];
                return answer == null ? false : !answer.isActive;
              },
            ) <
            0;
  }

  void _expand() {
    _isExpanded = !_isExpanded;

    final answer = _answer;
    if (answer != null && answer.action == ActionRequired.fromTeacher) {
      // Flag the answer as being actionned
      _student!.allAnswers[widget.question] =
          answer.copyWith(actionRequired: ActionRequired.none);
    }
    _answer = _student!.allAnswers[widget.question];

    setState(() {});
  }

  Future<void> _addOrModifyQuestion() async {
    final questions = Provider.of<AllQuestions>(context, listen: false);
    final currentStudent =
        ModalRoute.of(context)!.settings.arguments as Student?;

    final question = await showDialog<Question>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) => NewQuestionAlertDialog(
        section: widget.sectionIndex,
        student: currentStudent,
        title: widget.question?.text,
        deleteCallback: widget.questionView == QuestionView.modifyForAllStudents
            ? _deleteQuestionCallback
            : null,
      ),
    );
    if (question == null) return;

    if (widget.question == null) {
      questions.addToAll(question,
          students: _students, currentStudent: currentStudent);
    } else {
      var newQuestion = widget.question!.copyWith(text: question.text);
      questions.modifyToAll(newQuestion,
          students: _students, currentStudent: currentStudent);
    }
    setState(() {});
  }

  void _deleteQuestionCallback() {
    final questions = Provider.of<AllQuestions>(context, listen: false);
    final students = Provider.of<AllStudents>(context, listen: false);
    questions.removeToAll(widget.question!, students: students);
    setState(() {});
  }

  void _onStateChange(VoidCallback func) {
    _isExpanded = false;
    setState(() {});
  }

  void _addComment(String answerText, {required bool isPhoto}) {
    final currentAnswer = _student!.allAnswers[widget.question]!;

    currentAnswer.addToDiscussion(Message(
      name: _loginInfo.user!.name,
      text: answerText,
      isPhotoUrl: isPhoto,
    ));

    // Inform the changing of status
    late final ActionRequired newStatus;
    if (_loginInfo.loginType == LoginType.student) {
      newStatus = ActionRequired.fromTeacher;
    } else if (_loginInfo.loginType == LoginType.teacher) {
      newStatus = ActionRequired.fromStudent;
    } else {
      throw const NotLoggedIn();
    }
    _student!.allAnswers[widget.question] =
        currentAnswer.copyWith(text: answerText, actionRequired: newStatus);

    _answer = _student!.allAnswers[widget.question];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final answer = _answer;

    late final bool hasAction;
    if (_loginInfo.loginType == LoginType.student) {
      hasAction = answer != null && answer.action == ActionRequired.fromStudent;
    } else if (_loginInfo.loginType == LoginType.teacher) {
      hasAction = answer != null && answer.action == ActionRequired.fromTeacher;
    } else {
      throw const NotLoggedIn();
    }

    return TakingActionNotifier(
      number: _loginInfo.loginType == LoginType.teacher && hasAction ? 0 : null,
      left: 10,
      child: Card(
        elevation: 5,
        child: Column(
          children: [
            ListTile(
              title: QuestionPart(
                question: widget.question,
                studentId: widget.studentId,
                hasAction: hasAction,
              ),
              trailing: _trailingBuilder(hasAction),
              onTap: widget.questionView == QuestionView.normal
                  ? _expand
                  : _addOrModifyQuestion,
            ),
            if (_isExpanded && widget.questionView == QuestionView.normal)
              AnswerPart(
                widget.question!,
                onStateChange: _onStateChange,
                studentId: widget.studentId,
                addAnswerCallback: _addComment,
              ),
          ],
        ),
      ),
    );
  }

  Widget? _trailingBuilder(bool hasAction) {
    if (_loginInfo.loginType == LoginType.student) {
      return TakingActionNotifier(
        number: hasAction ? 1 : null,
        forcedText: "?",
        borderColor: Colors.black,
        child: const Text(''),
      );
    } else if (_loginInfo.loginType == LoginType.teacher) {
      return widget.question == null
          ? QuestionAddButton(
              newQuestionCallback: _addOrModifyQuestion,
            )
          : widget.questionView != QuestionView.normal
              ? QuestionActivatedState(
                  question: widget.question!,
                  studentId: widget.studentId,
                  initialStatus: _isActive,
                  onStateChange: _onStateChange,
                  questionView: widget.questionView,
                )
              : QuestionValidateCheckmark(
                  question: widget.question!,
                  studentId: widget.studentId!,
                );
    } else {
      throw const NotLoggedIn();
    }
  }
}

class QuestionPart extends StatelessWidget {
  const QuestionPart({
    Key? key,
    required this.question,
    required this.studentId,
    required this.hasAction,
  }) : super(key: key);

  final Question? question;
  final String? studentId;
  final bool hasAction;

  TextStyle _pickTextStyle(Answer? answer) {
    if (answer == null) {
      return const TextStyle();
    }

    return TextStyle(
      color: answer.isAnswered ? Colors.black : Colors.red,
      fontWeight: hasAction ? FontWeight.bold : FontWeight.normal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final students = Provider.of<AllStudents>(context, listen: false);
    final student = studentId == null ? null : students[studentId];
    final answer = student == null ? null : student.allAnswers[question];

    return Text(question == null ? 'Nouvelle question' : question!.text,
        style: _pickTextStyle(answer));
  }
}

class QuestionAddButton extends StatelessWidget {
  const QuestionAddButton({Key? key, required this.newQuestionCallback})
      : super(key: key);
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

class QuestionActivatedState extends StatefulWidget {
  const QuestionActivatedState({
    Key? key,
    required this.studentId,
    required this.onStateChange,
    required this.initialStatus,
    required this.question,
    required this.questionView,
  }) : super(key: key);

  final String? studentId;
  final Question question;
  final bool initialStatus;
  final Function(VoidCallback) onStateChange;
  final QuestionView questionView;

  @override
  State<QuestionActivatedState> createState() => _QuestionActivator();
}

class _QuestionActivator extends State<QuestionActivatedState> {
  var _isActive = false;

  @override
  void initState() {
    super.initState();
    _isActive = widget.initialStatus;
  }

  Future<void> _toggleQuestionActiveState(value) async {
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
    if (student != null) {
      student.allAnswers[widget.question] =
          student.allAnswers[widget.question]!.copyWith(isActive: _isActive);
    } else {
      for (var student in students) {
        student.allAnswers[widget.question] =
            student.allAnswers[widget.question]!.copyWith(isActive: _isActive);
      }
    }
    widget.onStateChange(() {});
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Switch(onChanged: _toggleQuestionActiveState, value: _isActive);
  }
}

class QuestionValidateCheckmark extends StatefulWidget {
  const QuestionValidateCheckmark({
    Key? key,
    required this.question,
    required this.studentId,
  }) : super(key: key);

  final Question question;
  final String studentId;

  @override
  State<QuestionValidateCheckmark> createState() =>
      _QuestionValidateCheckmarkState();
}

class _QuestionValidateCheckmarkState extends State<QuestionValidateCheckmark> {
  void _validateAnswer(Student student, Answer answer) {
    // Reverse the status of the answer
    final newAnswer = answer.copyWith(
        isValidated: !answer.isValidated, actionRequired: ActionRequired.none);
    student.allAnswers[widget.question] = newAnswer;
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
          color: answer.isValidated ? Colors.green[600] : Colors.grey[300],
        ));
  }
}

class AnswerPart extends StatelessWidget {
  const AnswerPart(
    this.question, {
    Key? key,
    required this.onStateChange,
    required this.studentId,
    required this.addAnswerCallback,
  }) : super(key: key);

  final String? studentId;
  final Function(VoidCallback) onStateChange;
  final Question question;
  final Function(String, {required bool isPhoto}) addAnswerCallback;

  Future<void> _addPhoto() async {
    final imagePicker = ImagePicker();
    final imageXFile =
        await imagePicker.pickImage(source: ImageSource.camera, maxWidth: 600);
    if (imageXFile == null) return;

    // Image is in cache (imageXFile.path) is temporary
    final imageFile = File(imageXFile.path);

    // Move to hard drive
    // TODO: Move to server
    final appDir = await syspath.getApplicationDocumentsDirectory();
    final filename = path.basename(imageFile.path);
    final imageFileOnHardDrive =
        await imageFile.copy('${appDir.path}/$filename');

    addAnswerCallback(imageFileOnHardDrive.path, isPhoto: true);
  }

  @override
  Widget build(BuildContext context) {
    final students = Provider.of<AllStudents>(context, listen: false);
    final student = students[studentId];
    final answer = student.allAnswers[question]!;
    final loginInfo = Provider.of<LoginInformation>(context, listen: false);

    return Container(
      padding: const EdgeInsets.only(left: 40, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (loginInfo.loginType == LoginType.student)
            TextButton(
              onPressed: _addPhoto,
              style: TextButton.styleFrom(primary: Colors.grey[700]),
              child: Row(
                children: const [
                  Icon(Icons.camera_alt),
                  SizedBox(width: 10),
                  Text('Ajouter une photo'),
                ],
              ),
            ),
          if (answer.isActive && studentId != null)
            DiscussionListView(
                answer: answer, addMessageCallback: addAnswerCallback),
          const SizedBox(height: 15)
        ],
      ),
    );
  }
}

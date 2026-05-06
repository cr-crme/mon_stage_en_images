import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mon_stage_en_images/common/helpers/shared_preferences_manager.dart';
import 'package:mon_stage_en_images/common/misc/storage_service.dart';
import 'package:mon_stage_en_images/common/models/enum.dart';
import 'package:mon_stage_en_images/common/models/message.dart';
import 'package:mon_stage_en_images/common/models/question.dart';
import 'package:mon_stage_en_images/common/models/text_reader.dart';
import 'package:mon_stage_en_images/common/providers/all_answers.dart';
import 'package:mon_stage_en_images/common/providers/database.dart';
import 'package:mon_stage_en_images/common/providers/speecher.dart';
import 'package:mon_stage_en_images/common/widgets/animated_icon.dart';
import 'package:mon_stage_en_images/screens/q_and_a/widgets/discussion_tile.dart';
import 'package:provider/provider.dart';

class DiscussionListView extends StatefulWidget {
  const DiscussionListView({
    super.key,
    required this.studentId,
    required this.messages,
    required this.isAnswerValidated,
    required this.question,
    required this.manageAnswerCallback,
  });

  final String? studentId;
  final List<Message> messages;
  final bool isAnswerValidated;
  final Question question;
  final void Function({
    required String studentId,
    String? newTextEntry,
    bool? isPhoto,
    String? markAnswerAsDeleted,
    bool? markAsValidated,
  }) manageAnswerCallback;

  @override
  State<DiscussionListView> createState() => _DiscussionListViewState();
}

class _DiscussionListViewState extends State<DiscussionListView> {
  final _fieldText = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isVoiceRecording = false;
  String? _newMessage;

  @override
  void dispose() {
    _fieldText.dispose();
    super.dispose();
  }

  void _clearFieldText() {
    _fieldText.clear();
    setState(() {});
  }

  void _sendMessage({bool markAsValidated = false}) {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    if ((_newMessage == null || _newMessage!.isEmpty)) return;
    _manageAnswer(
        studentId: widget.studentId!,
        newTextEntry: _newMessage,
        isPhoto: false,
        markAsValidated: markAsValidated);

    _clearFieldText();
  }

  Future<void> _addPhoto(ImageSource source) async {
    final currentUser =
        Provider.of<Database>(context, listen: false).currentUser;
    if (currentUser == null) return;

    final imagePicker = ImagePicker();
    final imageXFile =
        await imagePicker.pickImage(source: source, maxWidth: 500);
    if (imageXFile == null) return;

    final imagePath = await StorageService.uploadImage(currentUser, imageXFile);
    _manageAnswer(
        studentId: widget.studentId!, newTextEntry: imagePath, isPhoto: true);
  }

  void _manageAnswer({
    required String studentId,
    String? newTextEntry,
    bool? isPhoto,
    String? markAnswerAsDeleted,
    bool markAsValidated = false,
  }) async {
    // If it is the very first time the teacher validates an answer, we want to
    // Show a pop explaining that the student can continue to see the question
    // But cannot modify his answer anymore.
    final prefs = SharedPreferencesController.instance;
    final showPopup = prefs.showValidationWarning;
    if (!mounted) return;

    if (markAsValidated && showPopup) {
      final accept = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Valider la question'),
                content: const Text(
                    'En cliquant sur ce bouton, vous terminez la discussion.\n'
                    'L\'élève pourra voir vos commentaires mais ne pourra plus y répondre.'),
                actions: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Annuler'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Valider'),
                  ),
                ],
              ));
      prefs.showValidationWarning = false;
      // If the user cancels, we don't want to continue.
      if (accept == null || !accept) return;
    }

    widget.manageAnswerCallback(
      studentId: studentId,
      newTextEntry: newTextEntry,
      isPhoto: isPhoto,
      markAnswerAsDeleted: markAnswerAsDeleted,
      markAsValidated: markAsValidated,
    );
    setState(() {});
  }

  void _showHelpWithMicrophoneDialog() {
    TextReader? reader;
    const String instructionsTitle = 'Fonctionnement';
    const String instructions =
        'Faire un seul petit clic sur le micro pour commencer à dicter.\n'
        'Quand vous avez fini, cessez simplement de parler ou cliquer '
        'une 2ème fois sur le micro.';

    Future<void> stopReading() async {
      if (reader != null) {
        reader!.stopReading();
        reader = null;
      }
    }

    Future<void> read() async {
      reader = TextReader();
      reader!.readText('$instructionsTitle.\n$instructions',
          hasFinishedCallback: stopReading);
    }

    showDialog(
        context: context,
        builder: (context) => PopScope(
              onPopInvokedWithResult: (didPop, result) async =>
                  await stopReading(),
              child: AlertDialog(
                title: const Text(instructionsTitle),
                content: Row(
                  children: [
                    const Flexible(child: Text(instructions)),
                    InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: read,
                        child: const SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.volume_up,
                              color: Colors.grey,
                            ))),
                  ],
                ),
              ),
            ));
  }

  void _dictateMessage() {
    final speecher = Provider.of<Speecher>(context, listen: false);
    speecher.startListening(
        onResultCallback: _onDictatedMessage,
        onErrorCallback: _terminateDictate);
    _isVoiceRecording = true;
    setState(() {});
  }

  void _terminateDictate() {
    final speecher = Provider.of<Speecher>(context, listen: false);
    speecher.stopListening();
    _isVoiceRecording = false;
    setState(() {});
  }

  void _onDictatedMessage(String message) {
    _fieldText.text += ' $message';
    _terminateDictate();
  }

  @override
  Widget build(BuildContext context) {
    final userType = Provider.of<Database>(context, listen: false).userType;

    final answer = widget.studentId == null
        ? null
        : AllAnswers.of(context, listen: false).filter(
            questionIds: [widget.question.id],
            studentIds: [widget.studentId!]).first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MessageListView(
          discussion: widget.messages,
          onDeleteMessage: (
              {required String studentId, required String answerId}) {
            _manageAnswer(studentId: studentId, markAnswerAsDeleted: answerId);
          },
        ),
        SizedBox(
          height: 4,
        ),
        if (widget.studentId != null && !widget.isAnswerValidated)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed:
                      kIsWeb ? null : () => _addPhoto(ImageSource.camera),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        kIsWeb ? Colors.grey : Theme.of(context).primaryColor,
                    side: BorderSide(
                        color: kIsWeb
                            ? Colors.grey
                            : Theme.of(context).primaryColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.camera_alt),
                      Padding(
                        padding: EdgeInsets.only(left: 15.0, right: 15.0),
                        child: Text('Caméra', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () => _addPhoto(ImageSource.gallery),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor),
                  child: Row(
                    children: [
                      Icon(Icons.image),
                      Padding(
                          padding: EdgeInsets.only(left: 15.0, right: 15.0),
                          child:
                              Text('Galerie', style: TextStyle(fontSize: 16))),
                    ],
                  ),
                )
              ],
            ),
          ),
        if (widget.studentId != null && !widget.isAnswerValidated)
          Container(
            padding: const EdgeInsets.only(left: 15),
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: TextFormField(
                  autocorrect: userType != UserType.student,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                Theme.of(context).primaryColor.withAlpha(150))),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                Theme.of(context).primaryColor.withAlpha(150))),
                    labelStyle: const TextStyle(color: Colors.black),
                    labelText: userType == UserType.student
                        ? 'Ajouter une réponse'
                        : 'Ajouter un commentaire',
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 35,
                          height: 35,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onLongPress: _showHelpWithMicrophoneDialog,
                            onTap: () => _dictateMessage(),
                            child: _isVoiceRecording
                                ? const CustomAnimatedIcon(
                                    maxSize: 25,
                                    minSize: 20,
                                    color: Colors.red,
                                  )
                                : const CustomStaticIcon(
                                    boxSize: 25,
                                    iconSize: 20,
                                    color: Colors.black87,
                                  ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.black87),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ),
                  onSaved: (value) => _newMessage = value,
                  onFieldSubmitted: (value) => _sendMessage(),
                  controller: _fieldText,
                ),
              ),
            ),
          ),
        if (userType == UserType.teacher &&
            widget.studentId != null &&
            answer!.hasAnswer)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: answer.isValidated
                  ? OutlinedButton(
                      child: Text('Rouvrir la question',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary)),
                      onPressed: () => _manageAnswer(
                          studentId: widget.studentId!, markAsValidated: false),
                    )
                  : ElevatedButton.icon(
                      onPressed: () {
                        _fieldText.text.isEmpty
                            ? _manageAnswer(
                                studentId: widget.studentId!,
                                markAsValidated: true)
                            : _sendMessage(markAsValidated: true);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: null),
                      icon: const Icon(Icons.check),
                      label: const Text('Clore la discussion'),
                    ),
            ),
          ),
      ],
    );
  }
}

class _MessageListView extends StatefulWidget {
  const _MessageListView(
      {required this.discussion, required this.onDeleteMessage});

  final List<Message> discussion;
  final Function({required String studentId, required String answerId})
      onDeleteMessage;

  @override
  State<_MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<_MessageListView> {
  late final ScrollController scroller;

  void _scrollDown() {
    // Scolling "min" brings us to the end. See comment below.
    scroller.animateTo(
      scroller.position.minScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void initState() {
    scroller = ScrollController();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) _scrollDown();
    });
  }

  @override
  void didUpdateWidget(covariant _MessageListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.discussion.length > oldWidget.discussion.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) _scrollDown();
      });
    }
  }

  @override
  void dispose() {
    scroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reversedList = widget.discussion.reversed.toList();

    // We have to reverse the answers so last appears first allowing to "scroll"
    // to the end without having to load the photo to know their size. Since we
    // want the discussion to be chronologically, we reverse this one too.
    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          padding: const EdgeInsets.only(left: 15),
          // This NotificationListener absorbs scroll events
          // and prevent their propagation up to [QuestionAndAnswerPage]
          // so the inner scrolls won't trigger a setState in the notification
          // listener there.
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) => true,
            child: RawScrollbar(
              thumbVisibility: true,
              controller: scroller,
              thickness: 7,
              minThumbLength: 75,
              thumbColor: Colors.grey[700],
              radius: const Radius.circular(20),
              child: ListView.builder(
                shrinkWrap: true,
                reverse: true,
                controller: scroller,
                itemBuilder: (context, index) => Column(
                  children: [
                    DiscussionTile(
                      discussion: reversedList[index],
                      isLast: index == 0,
                      onDeleted: (String studentId) => widget.onDeleteMessage(
                          studentId: studentId,
                          answerId: reversedList[index].id),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
                itemCount: widget.discussion.length,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

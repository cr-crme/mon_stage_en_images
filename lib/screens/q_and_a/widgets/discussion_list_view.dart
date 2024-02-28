import 'dart:async';

import 'package:defi_photo/common/misc/storage_service.dart';
import 'package:defi_photo/common/models/database.dart';
import 'package:defi_photo/common/models/enum.dart';
import 'package:defi_photo/common/models/message.dart';
import 'package:defi_photo/common/models/question.dart';
import 'package:defi_photo/common/models/text_reader.dart';
import 'package:defi_photo/common/models/user.dart';
import 'package:defi_photo/common/providers/all_answers.dart';
import 'package:defi_photo/common/providers/speecher.dart';
import 'package:defi_photo/common/widgets/animated_icon.dart';
import 'package:defi_photo/screens/q_and_a/widgets/discussion_tile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiscussionListView extends StatefulWidget {
  const DiscussionListView({
    super.key,
    required this.messages,
    required this.isAnswerValidated,
    required this.student,
    required this.question,
    required this.manageAnswerCallback,
  });

  final List<Message> messages;
  final bool isAnswerValidated;
  final User? student;
  final Question question;
  final void Function({
    String? newTextEntry,
    bool? isPhoto,
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
    super.dispose();
    _fieldText.dispose();
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
        newTextEntry: _newMessage,
        isPhoto: false,
        markAsValidated: markAsValidated);

    _clearFieldText();
  }

  Future<void> _addPhoto(ImageSource source) async {
    final imagePicker = ImagePicker();
    final imageXFile =
        await imagePicker.pickImage(source: source, maxWidth: 500);
    if (imageXFile == null) return;

    // // Image is in cache (imageXFile.path) is temporary
    // final imageFile = File(imageXFile.path);

    // // Move to hard drive
    // final appDir = await syspath.getApplicationDocumentsDirectory();
    // final filename = path.basename(imageFile.path);
    // final imageFileOnHardDrive =
    //     await imageFile.copy('${appDir.path}/$filename');

    final imagePath =
        await StorageService.uploadImage(widget.student!, imageXFile);

    _manageAnswer(newTextEntry: imagePath, isPhoto: true);
  }

  void _manageAnswer({
    String? newTextEntry,
    bool? isPhoto,
    bool markAsValidated = false,
  }) async {
    // If it is the very first time the teacher validates an answer, we want to
    // show a pop explaining that the student can continue to see the question
    // but cannot modify his answer anymore.
    final showPopup = (await SharedPreferences.getInstance())
            .getBool('showValidatingWarning') ??
        true;
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
      (await SharedPreferences.getInstance())
          .setBool('showValidatingWarning', false);
      // If the user cancels, we don't want to continue.
      if (accept == null || !accept) return;
    }

    widget.manageAnswerCallback(
      newTextEntry: newTextEntry,
      isPhoto: isPhoto,
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
      reader!.read(
          Question('$instructionsTitle\n$instructions',
              section: -1, defaultTarget: Target.none),
          null,
          hasFinishedCallback: stopReading);
    }

    showDialog(
        context: context,
        builder: (context) => PopScope(
              onPopInvoked: (didPop) async => await stopReading(),
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
    final userType =
        Provider.of<Database>(context, listen: false).currentUser!.userType;

    final answer = widget.student == null
        ? null
        : Provider.of<AllAnswers>(context, listen: false).filter(
            questionIds: [widget.question.id],
            studentIds: [widget.student!.id]).first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MessageListView(
          discussion: widget.messages,
        ),
        if (userType == UserType.student && !widget.isAnswerValidated)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => _addPhoto(ImageSource.camera),
                  style:
                      TextButton.styleFrom(backgroundColor: Colors.grey[700]),
                  child: const Row(
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
                TextButton(
                  onPressed: () => _addPhoto(ImageSource.gallery),
                  style:
                      TextButton.styleFrom(backgroundColor: Colors.grey[700]),
                  child: const Row(
                    children: [
                      Icon(Icons.image),
                      Padding(
                        padding: EdgeInsets.only(left: 15.0, right: 15.0),
                        child: Text('Galerie', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        if (!widget.isAnswerValidated && widget.student != null)
          Container(
            padding: const EdgeInsets.only(left: 15),
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: TextFormField(
                  autocorrect: userType == UserType.student ? false : true,
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
            widget.student != null &&
            answer!.hasAnswer)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: answer.isValidated
                  ? OutlinedButton(
                      child: Text('Rouvrir la question',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary)),
                      onPressed: () => _manageAnswer(markAsValidated: false),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        _fieldText.text.isEmpty
                            ? _manageAnswer(markAsValidated: true)
                            : _sendMessage(markAsValidated: true);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: null),
                      child: const Text('Valider la question'),
                    ),
            ),
          ),
      ],
    );
  }
}

class _MessageListView extends StatelessWidget {
  const _MessageListView({required this.discussion});

  final List<Message> discussion;

  void _scrollDown(ScrollController scroller) {
    // Scolling "min" brings us to the end. See comment below.
    scroller.animateTo(
      scroller.position.minScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scroller = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollDown(scroller));

    // We have to reverse the answers so last appears first allowing to "scroll"
    // to the end without having to load the photo to know their size. Since we
    // want the discussion to be chronologically, we reverse this one too.
    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          padding: const EdgeInsets.only(left: 15),
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
                    discussion: discussion.reversed.toList()[index],
                    isLast: index == 0,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
              itemCount: discussion.length,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '/common/misc/storage_service.dart';
import '/common/models/database.dart';
import '/common/models/enum.dart';
import '/common/models/message.dart';
import '/common/models/question.dart';
import '/common/models/student.dart';
import '/common/providers/speecher.dart';
import 'discussion_tile.dart';

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
  final Student? student;
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
  }) {
    widget.manageAnswerCallback(
      newTextEntry: newTextEntry,
      isPhoto: isPhoto,
      markAsValidated: markAsValidated,
    );
    setState(() {});
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
    final answer = widget.student?.allAnswers[widget.question]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MessageListView(
          discussion: widget.messages,
        ),
        if (userType == UserType.student && !widget.isAnswerValidated)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => _addPhoto(ImageSource.camera),
                style: TextButton.styleFrom(backgroundColor: Colors.grey[700]),
                child: Row(
                  children: const [
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
                style: TextButton.styleFrom(backgroundColor: Colors.grey[700]),
                child: Row(
                  children: const [
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
        if (!widget.isAnswerValidated && widget.student != null)
          Container(
            padding: const EdgeInsets.only(left: 15),
            child: Form(
              key: _formKey,
              child: TextFormField(
                autocorrect: userType == UserType.student ? false : true,
                decoration: InputDecoration(
                  labelText: userType == UserType.student
                      ? 'Ajouter une réponse'
                      : 'Ajouter un commentaire',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTapDown: (_) => _dictateMessage(),
                        child: Icon(
                          Icons.mic,
                          color: _isVoiceRecording ? Colors.red : Colors.grey,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
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
                      child: const Text('Terminer et valider la question',
                          style: TextStyle(color: Colors.black)),
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
                      discussion: discussion.reversed.toList()[index]),
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

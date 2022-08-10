import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspath;
import 'package:provider/provider.dart';

import './discussion_tile.dart';
import '../../../common/models/answer.dart';
import '../../../common/models/enum.dart';
import '../../../common/models/message.dart';
import '../../../common/providers/login_information.dart';

class DiscussionListView extends StatefulWidget {
  const DiscussionListView({
    Key? key,
    required this.answer,
    required this.addMessageCallback,
  }) : super(key: key);

  final Answer? answer;
  final Function(String, {bool isPhoto}) addMessageCallback;

  @override
  State<DiscussionListView> createState() => _DiscussionListViewState();
}

class _DiscussionListViewState extends State<DiscussionListView> {
  final fieldText = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _newMessage;

  @override
  void dispose() {
    super.dispose();
    fieldText.dispose();
  }

  void _clearFieldText() {
    fieldText.clear();
    setState(() {});
  }

  void _sendMessage() {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    if (_newMessage == null || _newMessage!.isEmpty) return;

    widget.addMessageCallback(_newMessage!);

    _clearFieldText();
    setState(() {});
  }

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

    widget.addMessageCallback(imageFileOnHardDrive.path, isPhoto: true);
  }

  @override
  Widget build(BuildContext context) {
    final loginInfo = Provider.of<LoginInformation>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MessageListView(
          discussion: widget.answer!.discussion,
        ),
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
        Container(
          padding: const EdgeInsets.only(left: 15),
          child: Form(
            key: _formKey,
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Ajouter un commentaire',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.mic),
                      onPressed: () => debugPrint('coucou'),
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
              controller: fieldText,
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageListView extends StatelessWidget {
  const _MessageListView({Key? key, required this.discussion})
      : super(key: key);

  final List<Message> discussion;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (discussion.isEmpty)
          const Center(
              child: Text('En attente d\'une réponse',
                  style: TextStyle(color: Colors.red))),
        Container(
          padding: const EdgeInsets.only(left: 15),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) =>
                DiscussionTile(discussion: discussion[index]),
            itemCount: discussion.length,
          ),
        ),
      ],
    );
  }
}

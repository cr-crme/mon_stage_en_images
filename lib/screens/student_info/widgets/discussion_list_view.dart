import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './discussion_tile.dart';
import '../../../common/models/answer.dart';
import '../../../common/models/message.dart';
import '../../../common/providers/user.dart';

class DiscussionListView extends StatefulWidget {
  const DiscussionListView({
    Key? key,
    required this.answer,
  }) : super(key: key);

  final Answer? answer;

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

  void _clearText() {
    fieldText.clear();
    setState(() {});
  }

  void _sendMessage() {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    if (_newMessage == null || _newMessage!.isEmpty) return;

    widget.answer!.addMessage(Message(
      name: Provider.of<User>(context, listen: false).name,
      text: _newMessage!,
    ));

    _clearText();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MessageListView(
          discussion: widget.answer!.discussion,
        ),
        Container(
          padding: const EdgeInsets.only(left: 15),
          child: Form(
            key: _formKey,
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Ajouter un commentaire',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
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

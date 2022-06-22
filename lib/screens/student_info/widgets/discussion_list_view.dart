import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './discussion_tile.dart';
import '../../../common/models/answer.dart';
import '../../../common/models/message.dart';
import '../../../common/providers/user.dart';

// TODO: Fix the autoscroller (it is implemented, but it does not work)
// TODO: Fix when the text overflow (autowrapping)
// TODO: Fix the height of the comments when there is an autowrapping

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
  final _scrollController = ScrollController();
  var _needsScroll = true;

  final fieldText = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _newMessage;

  _scrollToEnd() async {
    if (_needsScroll) {
      _needsScroll = false;
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
    }
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
    _needsScroll = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_needsScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
      _needsScroll = false;
    }

    final discussion = widget.answer!.discussion;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Commentaire(s) : ', style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 4),
      discussion.isEmpty
          ? const Center(
              child: Text('Il n\'y a aucun message associé à cette question',
                  style: TextStyle(color: Colors.grey)))
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 10),
                    height: 26 * min(discussion.length.toDouble(), 8),
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: _scrollController,
                      itemBuilder: (context, index) =>
                          DiscussionTile(discussion: discussion[index]),
                      itemCount: discussion.length,
                    ),
                  ),
                ],
              ),
            ),
      Form(
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
          onFieldSubmitted: (value) => _sendMessage,
          controller: fieldText,
        ),
      ),
    ]);
  }
}

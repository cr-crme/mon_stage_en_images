import 'package:flutter/material.dart';

import './discussion_tile.dart';
import '../../../common/models/answer.dart';

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
  final _formKey = GlobalKey<FormState>();
  String? _newDiscussion;

  void _finalize(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    final discussion = widget.answer!.discussion;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Discussion : ', style: TextStyle(color: Colors.grey)),
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
                    height: 200,
                    child: ListView.builder(
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
          decoration:
              const InputDecoration(labelText: 'Ajouter un commentaire'),
          onSaved: (value) => _newDiscussion = value,
        ),
      ),
    ]);
  }
}

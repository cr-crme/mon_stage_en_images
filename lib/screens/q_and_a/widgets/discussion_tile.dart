import 'package:flutter/material.dart';

import '../../../common/models/message.dart';

class DiscussionTile extends StatelessWidget {
  const DiscussionTile({
    Key? key,
    required this.discussion,
  }) : super(key: key);

  final Message discussion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (discussion.isPhotoUrl) _showNameOfSender(),
        if (discussion.isPhotoUrl)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 15),
            child: FutureBuilder(builder: (context, snapshot) {
              return snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator())
                  : Image.network(discussion.text, fit: BoxFit.contain);
            }),
          ),
        if (!discussion.isPhotoUrl)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: _showNameOfSender()),
              Flexible(child: Text(discussion.text)),
            ],
          ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _showNameOfSender() {
    return Text('${discussion.name} : ',
        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold));
  }
}

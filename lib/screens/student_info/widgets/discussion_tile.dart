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
      children: [
        Row(
          children: [
            Text('${discussion.name} : '),
            Text(discussion.text),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

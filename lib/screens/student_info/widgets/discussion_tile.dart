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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
                child: Text(
              '${discussion.name} : ',
              style: TextStyle(
                  color: Colors.grey[600], fontWeight: FontWeight.bold),
            )),
            Flexible(child: Text(discussion.text)),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

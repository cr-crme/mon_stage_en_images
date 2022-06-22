import 'package:flutter/material.dart';

import '../../../common/models/discussion.dart';

class DiscussionTile extends StatelessWidget {
  const DiscussionTile({
    Key? key,
    required this.discussion,
  }) : super(key: key);

  final Discussion discussion;

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

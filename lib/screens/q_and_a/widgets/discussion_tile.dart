import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/misc/date_formatting.dart';
import 'package:mon_stage_en_images/common/misc/storage_service.dart';
import 'package:mon_stage_en_images/common/models/database.dart';
import 'package:mon_stage_en_images/common/models/enum.dart';
import 'package:mon_stage_en_images/common/models/message.dart';
import 'package:mon_stage_en_images/common/models/themes.dart';
import 'package:provider/provider.dart';

class DiscussionTile extends StatelessWidget {
  const DiscussionTile({
    super.key,
    required this.discussion,
    required this.isLast,
  });

  final Message discussion;
  final bool isLast;

  void _showImageFullScreen(context, {required Uint8List imageData}) {
    showDialog(
        context: context,
        builder: (context) => GestureDetector(
              onTap: () => Navigator.pop(context),
              child: AlertDialog(
                  content: Image.memory(imageData, fit: BoxFit.contain)),
            ));
  }

  @override
  Widget build(BuildContext context) {
    final currentUser =
        Provider.of<Database>(context, listen: false).currentUser!;

    final Color myColor = currentUser.userType == UserType.student
        ? studentTheme().colorScheme.primary
        : teacherTheme().colorScheme.primary;
    final Color otherColor = currentUser.userType == UserType.student
        ? teacherTheme().colorScheme.primary
        : studentTheme().colorScheme.primary;

    return Padding(
      padding: discussion.creatorId == currentUser.id
          ? const EdgeInsets.only(left: 30.0)
          : const EdgeInsets.only(right: 30.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: discussion.creatorId == currentUser.id
              ? myColor.withAlpha(80)
              : otherColor.withAlpha(80),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (discussion.isPhotoUrl) _showNameOfSender(),
            if (discussion.isPhotoUrl)
              FutureBuilder<Uint8List?>(
                  future: StorageService.getImage(discussion.text),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 1 / 4,
                          ),
                          const CircularProgressIndicator(),
                        ],
                      );
                    }

                    return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(left: 15, bottom: 5),
                        child: InkWell(
                          onTap: () => _showImageFullScreen(context,
                              imageData: snapshot.data!),
                          child: SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 1 / 4,
                              child: Image.memory(snapshot.data!,
                                  fit: BoxFit.cover)),
                        ));
                  }),
            if (!discussion.isPhotoUrl)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _showNameOfSender(),
                  Flexible(
                      child: Text(
                    discussion.text,
                    style: const TextStyle(fontSize: 16),
                  )),
                ],
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(discussion.creationTimeStamp.toFullDateFromEpoch()),
                if (discussion.creatorId == currentUser.id && isLast) ...[
                  Icon(
                    Icons.check,
                    color: Colors.blueGrey.withAlpha(150),
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'envoyé',
                    style: TextStyle(color: Colors.blueGrey.withAlpha(150)),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _showNameOfSender() {
    return Text('${discussion.name} : ',
        style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
            fontSize: 18));
  }
}

import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/models/text_reader.dart';

class AreYouSureContent extends StatelessWidget {
  const AreYouSureContent({
    super.key,
    required this.title,
    required this.content,
    this.extraContent,
    this.canReadAloud = false,
    required this.onConfirmed,
    required this.onCancelled,
  });

  final String title;
  final String content;
  final bool canReadAloud;
  final Widget? extraContent;
  final Function() onConfirmed;
  final Function() onCancelled;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              if (canReadAloud)
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: IconButton(
                      onPressed: () {
                        final textReader = TextReader();
                        textReader.readText(
                          content,
                          hasFinishedCallback: () => textReader.stopReading(),
                        );
                      },
                      icon: const Icon(Icons.volume_up)),
                ),
              Flexible(child: Text(content)),
            ],
          ),
          if (extraContent != null) extraContent!,
          SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: onCancelled,
                child: const Text('Annuler'),
              ),
              SizedBox(
                width: 20,
              ),
              ElevatedButton(
                onPressed: onConfirmed,
                child: const Text('Continuer'),
              ),
            ],
          )
        ],
      ),
    );
  }
}

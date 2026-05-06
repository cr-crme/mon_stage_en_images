import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextClipboardCopy extends StatefulWidget {
  const TextClipboardCopy({super.key, required this.text});

  final String text;

  @override
  State<TextClipboardCopy> createState() => _TextClipboardCopyState();
}

class _TextClipboardCopyState extends State<TextClipboardCopy> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(widget.text)),
        IconButton(
            onPressed: () async {
              final ClipboardData clipboardData =
                  ClipboardData(text: widget.text);
              await Clipboard.setData(clipboardData).then((_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('texte copié dans le presse papier')));
              });
            },
            icon: Icon(Icons.copy))
      ],
    );
  }
}

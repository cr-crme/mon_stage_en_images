import 'package:flutter/material.dart';

class AreYouSureDialog extends StatelessWidget {
  const AreYouSureDialog({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          child: const Text("Annuler"),
          onPressed: () => Navigator.pop(context, false),
        ),
        TextButton(
          child: const Text("Continuer"),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}

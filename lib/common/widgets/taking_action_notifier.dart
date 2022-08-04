import 'package:flutter/material.dart';

class TakingActionNotifier extends StatelessWidget {
  const TakingActionNotifier({
    Key? key,
    required this.child,
    this.title,
    this.left,
    this.top,
  }) : super(key: key);

  final Widget child;
  final String? title;
  final double? left;
  final double? top;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (title != null && title != "0")
          Positioned(
            left: left,
            top: top,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                title ?? "",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ),
      ],
    );
  }
}

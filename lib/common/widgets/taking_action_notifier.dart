import 'package:flutter/material.dart';

class TakingActionNotifier extends StatelessWidget {
  const TakingActionNotifier({
    Key? key,
    this.child,
    this.number,
    this.left,
    this.top,
    this.padding = 6,
    this.borderColor = Colors.white,
  }) : super(key: key);

  final Widget? child;
  final int? number;
  final double? left;
  final double? top;
  final double padding;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (child != null) child!,
        if (number != null)
          Positioned(
            left: left,
            top: top,
            child: Container(
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Text(
                number == 0 ? "" : number.toString(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
          ),
      ],
    );
  }
}

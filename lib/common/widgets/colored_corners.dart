import 'package:flutter/material.dart';

class ColoredCorners extends StatelessWidget {
  const ColoredCorners({
    Key? key,
    this.firstColor,
    this.secondColor,
    required this.child,
  }) : super(key: key);

  final Widget child;
  final LinearGradient? firstColor;
  final LinearGradient? secondColor;

  @override
  Widget build(BuildContext context) {
    if (firstColor != null && firstColor == null) {
      return Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height -
            MediaQuery.of(context).viewInsets.bottom,
        decoration: BoxDecoration(gradient: firstColor),
        child: child,
      );
    } else if (firstColor == null && firstColor != null) {
      Container(
        height: MediaQuery.of(context).size.height -
            MediaQuery.of(context).viewInsets.bottom,
        decoration: BoxDecoration(gradient: secondColor),
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: child,
      );
    } else if (firstColor != null && firstColor != null) {
      return Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).viewInsets.bottom,
            decoration: BoxDecoration(gradient: firstColor),
          ),
          Container(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).viewInsets.bottom,
            decoration: BoxDecoration(gradient: secondColor),
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: child,
          ),
        ],
      );
    }

    // If we get there simply return the child
    return child;
  }
}

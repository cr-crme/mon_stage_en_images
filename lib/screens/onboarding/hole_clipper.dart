import 'package:flutter/material.dart';

class HoleClipper extends CustomClipper<Path> {
  const HoleClipper(
      {required this.holeRect, this.radius = 12, this.makeRRect = true});

  final bool makeRRect;
  final double radius;
  final Rect holeRect;

  @override
  Path getClip(Size size) {
    Path path = Path();

    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final rrectFromHoleRect =
        RRect.fromRectAndRadius(holeRect, Radius.circular(radius));

    makeRRect ? path.addRRect(rrectFromHoleRect) : path.addRect(holeRect);
    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(covariant HoleClipper oldClipper) {
    // return oldClipper.holeRect != holeRect;
    debugPrint("shouldReclip is running");
    return true;
  }
}

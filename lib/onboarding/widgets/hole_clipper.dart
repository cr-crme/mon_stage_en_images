import 'package:flutter/material.dart';

///Takes the Rect drawn from the Render Box of the targeted onboarding Widget
///and substracts it to another path filling the whole view. Meant to be provided
///to the OnBoardingDialogClippedBackground widget as a background for the onboarding dialog.
class HoleClipper extends CustomClipper<Path> {
  const HoleClipper(
      {required this.holeRect, this.radius = 12, this.makeRRect = true});

  ///Whether the clipped zone should have rounded corners or not
  final bool makeRRect;

  ///Radius for the rounded corners clipped zone
  final double radius;

  ///Rect drawn from the RenderBox of the targeted onboarding Widget.
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
    // debugPrint("shouldReclip is running");
    return true;
  }
}

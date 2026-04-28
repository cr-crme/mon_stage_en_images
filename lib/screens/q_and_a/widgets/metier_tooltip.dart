import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/models/section.dart';
import 'package:mon_stage_en_images/common/providers/database.dart';
import 'package:provider/provider.dart';

class MetierTooltip extends StatelessWidget {
  const MetierTooltip(
      {super.key,
      required this.child,
      required this.sectionIndex,
      this.setOffset,
      this.maxWidth,
      this.minWidth});

  final Widget child;
  final int sectionIndex;
  final double? maxWidth;
  final double? minWidth;

  final Offset Function(TooltipPositionContext)? setOffset;

  static Offset defaultOffset(TooltipPositionContext context) => Offset(
      context.target.dx - context.targetSize.width / 2, context.target.dy + 20);

  @override
  Widget build(BuildContext context) {
    final userType = Provider.of<Database>(context, listen: false).userType;

    return RawTooltip(
        hoverDelay: Duration.zero,
        semanticsTooltip: Section.description(sectionIndex, userType),
        positionDelegate: (TooltipPositionContext context) =>
            (setOffset ?? defaultOffset)(context),
        tooltipBuilder: (context, animation) => ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: clampDouble(MediaQuery.sizeOf(context).width / 1.8,
                      minWidth ?? 100, maxWidth ?? 400)),
              child: Card(
                surfaceTintColor: Section.color(sectionIndex).shade900,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(Section.description(sectionIndex, userType)),
                ),
              ),
            ),
        triggerMode: TooltipTriggerMode.manual,
        child: child);
  }
}

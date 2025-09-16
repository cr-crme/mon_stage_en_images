import 'package:flutter/cupertino.dart';

class OnboardingStep {
  const OnboardingStep({
    required this.widgetKey,
    required this.id,
    required this.rank,
    required this.message,
    this.isLast = false,
  });

  final GlobalKey widgetKey;
  final String id;
  final int rank;
  final bool isLast;
  final String message;

  Rect? get rectFromWidgetKey {
    if (widgetKey.currentContext == null ||
        !widgetKey.currentContext!.mounted) {
      return null;
    }

    final widgetObject =
        widgetKey.currentContext!.findRenderObject() as RenderBox;

    final insets = EdgeInsets.all(12);

    final offset = widgetObject.localToGlobal(
        Offset(0, -MediaQuery.of(widgetKey.currentContext!).padding.top));
    final size = widgetObject.size;

    return insets.inflateRect(offset & size);
  }
}

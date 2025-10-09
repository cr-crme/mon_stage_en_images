import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/onboarding/application/onboarding_keys_service.dart';
import 'package:mon_stage_en_images/onboarding/models/onboarding_step.dart';
import 'package:mon_stage_en_images/onboarding/widgets/hole_clipper.dart';

///Main widget for displaying an onboarding dialog with a background clipped
///to highlight the targeted Widget.
class OnboardingOverlayClippedBackground extends StatefulWidget {
  const OnboardingOverlayClippedBackground(
      {super.key,
      this.manualHoleRect = Rect.zero,
      this.onboardingStep,
      this.complete,
      this.onForward,
      this.onBackward});

  ///Optional holeRect for overriding the clip provided by the globalKey (onboardingStep property)
  final Rect? manualHoleRect;
  final OnboardingStep? onboardingStep;
  String? get targetId => onboardingStep?.targetId;

  final void Function()? onForward;
  final void Function()? onBackward;
  final void Function()? complete;

  @override
  State<OnboardingOverlayClippedBackground> createState() =>
      _OnboardingOverlayClippedBackgroundState();

  ///function to be called when displaying the actual dialog
  ///allows the injection of an outter context
  showOnBoardingDialog(context) async {
    await showDialog(
        useRootNavigator: true,
        barrierColor: Colors.transparent,
        barrierDismissible: false,
        context: context,
        builder: (dialogContext) => this);
  }
}

class _OnboardingOverlayClippedBackgroundState
    extends State<OnboardingOverlayClippedBackground>
    with WidgetsBindingObserver {
  Rect? newHoleRect;

  ///Get the RenderBox from the widgetKey getter, which is linked to the targeted Widget in the tree
  ///Uses the Render Box to draw a Rect with an absolute position on the screen and some padding around.
  Future<Rect?> _rectFromWidgetKeyLabel(String keyLabel) async {
    GlobalKey? targetKey;
    Rect? rect;
    while (targetKey == null) {
      await Future.delayed(Duration(milliseconds: 200));
      targetKey = OnboardingKeysService.instance.findTargetKeyWithId(keyLabel);
      await Future.delayed(Duration(milliseconds: 100));
      debugPrint("_rectFromWidgetKeyLabel : waiting for targetKey");
    }

    if (targetKey.currentContext == null ||
        !targetKey.currentContext!.mounted) {
      debugPrint("_rectFromWidgetKeyLabel : cannot obtain context");
      return null;
    }
    final context = targetKey.currentContext!;
    debugPrint("_rectFromWidgetKeyLabel : context is $context");

    RenderBox? widgetObject;
    while (widgetObject == null) {
      debugPrint("waiting for WidgetObject RenderBox");
      if (!context.mounted) {
        debugPrint(
            "_rectFromWidgetKeyLabel : context is not mounted ahen trying to get widgetObject, returning");
        return null;
      }
      widgetObject = context.findRenderObject() as RenderBox?;
      await Future.delayed(Duration(milliseconds: 100));
    }
    final insets = EdgeInsets.all(12);

    // while (!context.mounted) {
    //   Future.delayed(Duration(milliseconds: 500));
    //   debugPrint("_rectFromWidgetKeyLabel :waiting for context to be mounted");
    // }
    if (!context.mounted) {
      debugPrint(
          "_rectFromWidgetKeyLabel :mounted is false after defining insets");
      return null;
    }

    final vertOffset = Scaffold.of(context).hasAppBar
        ? MediaQuery.of(context).padding.top
        : MediaQuery.of(context).padding.top;

    final offset = widgetObject.localToGlobal(Offset(0, 0 - vertOffset));
    final size = widgetObject.size;

    rect = insets.inflateRect(offset & size);

    if (!mounted) {
      debugPrint(
          "_rectFromWidgetKeyLabel : context isn't mounted after getting widgetObject's renderbox, returning null");
      return null;
    }
    debugPrint("rect is $rect");
    return rect;
  }

  @override
  Widget build(BuildContext context) {
    // Triggering rebuilds upon sudden window enlargement or shrinking on web/desktop
    // to overcome limitations of didChangeMetrics
    MediaQuery.sizeOf(context);

    return FutureBuilder(
      future: _rectFromWidgetKeyLabel(widget.targetId!),
      builder: (build, snapshot) => Stack(
        children: [
          //Ignoring click events inside the scrim's window
          AbsorbPointer(
            absorbing: true,
            child: Container(
                // color: Colors.red,
                ),
          ),
          ClipPath(
            clipper: widget.manualHoleRect == null
                ? null
                : HoleClipper(
                    holeRect: snapshot.data ?? widget.manualHoleRect!),
            child: Container(
              decoration:
                  BoxDecoration(color: Colors.black.withValues(alpha: 0.6)),
              height: double.infinity,
              width: double.infinity,
            ),
          ),
          Center(
            child: FloatingActionButton(
              onPressed: widget.complete,
              child: Icon(Icons.check),
            ),
          ),
          //TODO appliquer style pour le dialog
          Dialog(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                spacing: 12,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.onboardingStep!.message),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 600),
                    child: SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 12,
                        runAlignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.spaceEvenly,
                        children: [
                          if (widget.onBackward != null)
                            OutlinedButton.icon(
                                onPressed: () {
                                  widget.onBackward?.call();
                                  // Navigator.pop(context);
                                },
                                iconAlignment: IconAlignment.start,
                                icon: Icon(Icons.keyboard_arrow_left_sharp),
                                label: Text("Précédent")),
                          FilledButton.icon(
                            onPressed: () async {
                              widget.onForward?.call();
                              // Navigator.pop(context);
                            },
                            label: Text("Suivant"),
                            icon: Icon(Icons.keyboard_arrow_right_sharp),
                            iconAlignment: IconAlignment.end,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

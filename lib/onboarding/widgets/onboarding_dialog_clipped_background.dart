import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/onboarding/application/onboarding_keys_service.dart';
import 'package:mon_stage_en_images/onboarding/application/onboarding_observer.dart';
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
}

class _OnboardingOverlayClippedBackgroundState
    extends State<OnboardingOverlayClippedBackground>
    with WidgetsBindingObserver {
  Rect? newHoleRect;

  VoidCallback? _animationListener;
  AnimationStatus? _status;
  bool get showRect => _status == AnimationStatus.completed;

  late Future<Rect?> _futureRect;

  @override
  void initState() {
    _status = AnimationStatus.completed;
    _futureRect = _rectFromWidgetKeyLabel(widget.targetId!);
    // Listening to the state of a navigation animation and trigerring redraws of the rect.
    // prevents wrong offset and size from early call to _rectFromWidgetKeyLabel during
    // a pageView transition.
    _animationListener = () {
      debugPrint(
          "Onboardingnavigation observer for AnimationStatus in OnboardingDialog : ${OnboardingNavigatorObserver.instance.animationStatus.value}");
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          _status = OnboardingNavigatorObserver.instance.animationStatus.value;
          if (_status == AnimationStatus.completed) {
            _futureRect = _rectFromWidgetKeyLabel(widget.targetId!);
            setState(() {});
          }
        },
      );
    };
    OnboardingNavigatorObserver.instance.animationStatus
        .addListener(_animationListener!);

    super.initState();
  }

  @override
  void dispose() {
    OnboardingNavigatorObserver.instance.animationStatus
        .removeListener(_animationListener!);
    super.dispose();
  }

  //rect refresh when the onboardingStep provided to this widget changes.
  @override
  void didUpdateWidget(covariant OnboardingOverlayClippedBackground oldWidget) {
    if (oldWidget.targetId != widget.targetId) {
      _futureRect = _rectFromWidgetKeyLabel(widget.targetId!);
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  ///Get the RenderBox from the widgetKey getter, which is linked to the targeted Widget in the tree
  ///Uses the Render Box to draw a Rect with an absolute position on the screen and some padding around.
  Future<Rect?> _rectFromWidgetKeyLabel(String keyLabel) async {
    GlobalKey? targetKey;
    Rect? rect;
    final int maxAttempts = 50;
    int attempts = 0;

    while (targetKey == null && attempts <= maxAttempts) {
      await Future.delayed(Duration(milliseconds: 100));
      targetKey = OnboardingKeysService.instance.findTargetKeyWithId(keyLabel);
      // await Future.delayed(Duration(milliseconds: 300));
      debugPrint(
          "_rectFromWidgetKeyLabel : waiting for targetKey with label $keyLabel");
      attempts++;
    }

    if (targetKey?.currentContext == null ||
        !targetKey!.currentContext!.mounted) {
      debugPrint("_rectFromWidgetKeyLabel : cannot obtain context");
      return null;
    }
    final targetContext = targetKey.currentContext!;
    debugPrint("_rectFromWidgetKeyLabel : context is $targetContext");

    RenderBox? widgetObject;
    while (widgetObject == null) {
      debugPrint("waiting for WidgetObject RenderBox");
      if (!targetContext.mounted) {
        debugPrint(
            "_rectFromWidgetKeyLabel : context is not mounted when trying to get widgetObject, returning");
        return null;
      }
      widgetObject = targetContext.findRenderObject() as RenderBox?;
      await Future.delayed(Duration(milliseconds: 100));
    }

    if (!targetContext.mounted) {
      debugPrint(
          "_rectFromWidgetKeyLabel : mounted is false after defining insets");
      return null;
    }

    final vertOffset = MediaQuery.of(targetContext).padding.top;

    final offset = widgetObject.localToGlobal(Offset(0, 0 - vertOffset));
    final size = widgetObject.size;
    final insets = EdgeInsets.all(12);

    rect = insets.inflateRect(offset & size);

    if (!mounted) {
      debugPrint(
          "_rectFromWidgetKeyLabel : context isn't mounted after getting widgetObject's renderbox, returning null");
      return null;
    }
    debugPrint("_rectFromWidgetKeyLabel : rect is $rect");
    return rect;
  }

  @override
  Widget build(BuildContext context) {
    // Triggering rebuilds upon sudden window enlargement or shrinking on web/desktop
    // to overcome limitations of didChangeMetrics
    MediaQuery.sizeOf(context);

    debugPrint(
        "OnboardingDialogClippedBackground build : animations status is $_status");
    return FutureBuilder(
      // key: ValueKey(widget.targetId),
      future: showRect
          //returning _futurRect variable instead of calling _rectFromWidgetKeyLabel
          //to prevent unwanted rebuilds
          ? _futureRect
          : Future.value(null),
      builder: (build, AsyncSnapshot<Rect?> snapshot) => Stack(
        children: [
          //Ignoring click events inside the scrim
          AbsorbPointer(
            absorbing: true,
            child: Container(),
          ),
          //Clipping the area of the screen where the targeted widget is visible
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
          //Shortcut to complete the onboarding
          // TODO Add showDebugOverlay
          if (kDebugMode)
            Center(
              child: FloatingActionButton(
                onPressed: widget.complete,
                child: Icon(Icons.check),
              ),
            ),
          //Displays the onboardingStep
          Dialog(
            backgroundColor: Theme.of(context).colorScheme.scrim.withAlpha(225),
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      width: 4, color: Theme.of(context).primaryColor)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  spacing: 12,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.onboardingStep!.message,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: Theme.of(context).cardColor)),
                    SizedBox(
                      height: 4,
                    ),
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
                                  label: Text(
                                    "Précédent",
                                    style: TextStyle(
                                        fontSize: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .fontSize),
                                  )),
                            FilledButton.icon(
                              onPressed: () async {
                                widget.onForward?.call();
                                // Navigator.pop(context);
                              },
                              label: Text("Suivant",
                                  style: TextStyle(
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .fontSize)),
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
            ),
          )
        ],
      ),
    );
  }
}

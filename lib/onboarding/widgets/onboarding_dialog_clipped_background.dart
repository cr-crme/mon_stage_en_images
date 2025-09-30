import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/onboarding/models/onboarding_step.dart';
import 'package:mon_stage_en_images/onboarding/widgets/hole_clipper.dart';

///Main widget for displaying an onboarding dialog with a background clipped
///to highlight the targeted Widget.
class OnboardingDialogClippedBackground extends StatefulWidget {
  const OnboardingDialogClippedBackground(
      {super.key,
      this.manualHoleRect = Rect.zero,
      this.onboardingStep,
      this.onForward,
      this.onBackward});

  ///Optional holeRect for overriding the clip provided by the globalKey (onboardingStep property)
  final Rect? manualHoleRect;
  final OnboardingStep? onboardingStep;

  final void Function()? onForward;
  final void Function()? onBackward;

  @override
  State<OnboardingDialogClippedBackground> createState() =>
      _OnboardingDialogClippedBackgroundState();

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

class _OnboardingDialogClippedBackgroundState
    extends State<OnboardingDialogClippedBackground>
    with WidgetsBindingObserver {
  Rect? newHoleRect;

  @override
  void initState() {
    super.initState();
    // We want to watch this object in order to adapt the clipper when view size changes
    // Rect is declared again when view size changes, to match the actual position of the
    // spotlighted widget on the screen.
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateRect();
    });
    debugPrint(newHoleRect.toString());
  }

  //Watching view size changes and updating the Rect accordingly
  @override
  void didChangeMetrics() {
    _updateRect();
    super.didChangeMetrics();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  ///updates to the current Rect used for defining the clipped background area
  void _updateRect() {
    setState(() {
      newHoleRect = widget.onboardingStep!.rectFromWidgetKey;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Triggering rebuilds upon sudden window enlargement or shrinking on web/desktop
    // to overcome limitations of didChangeMetrics
    MediaQuery.sizeOf(context);
    //Only necessary on web/desktop, see previous comment
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _updateRect(),
    );

    return Stack(
      children: [
        ClipPath(
          clipper: widget.manualHoleRect == null
              ? null
              : HoleClipper(holeRect: newHoleRect ?? widget.manualHoleRect!),
          child: Container(
            decoration:
                BoxDecoration(color: Colors.black.withValues(alpha: 0.6)),
            height: double.infinity,
            width: double.infinity,
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
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                            onPressed: () {
                              widget.onBackward?.call();
                              Navigator.pop(context);
                            },
                            label: Text("Précédent")),
                        FilledButton.icon(
                          onPressed: () async {
                            widget.onForward?.call();
                            Navigator.pop(context);
                          },
                          label: Text("Suivant"),
                          icon: Icon(Icons.arrow_right_alt),
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
    );
  }
}

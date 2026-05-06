import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/helpers/responsive_service.dart';

typedef AdaptiveModalBuilder<T> = Widget Function(
  BuildContext context,
  // this is to enforce the type returned by the "pop dialog pattern",
  // like in a regular showDialog<T> or showModalBottomSheet<T> (likely a bool)
  void Function([T? result]) pop,
);

extension AdaptiveModal on BuildContext {
  /// Adds a new [PopupRoute]  onto the navigator stack, which content
  /// is driven by the screen width and the platform. Web and large screens
  /// show a [Dialog] while mobile devices display a [BottomSheet]
  Future<T?> showAdaptiveModal<T extends Object>(
      {
      /// Content to be displayed inside the modal
      required AdaptiveModalBuilder<T> builder,

      /// Whether the modal can be dismissed by tapping the barrier. Defaults to true
      bool isBarrierDismissible = true}) async {
    // Allows the state of the content to be preserved upon modal switching
    final GlobalKey contentKey = GlobalObjectKey('AdaptiveModalContent');

    return await Navigator.of(this).push(_AdaptiveModalRoute<T>(
        builder: builder,
        context: this,
        contentKey: contentKey,
        isBarrierDismissible: isBarrierDismissible));
  }
}

/// A [PopupRoute] to display either a [Dialog] or a [BottomSheet] depending on screen width
/// and platform type. T is the type expected to be returned when popping the route.
class _AdaptiveModalRoute<T> extends PopupRoute<T> {
  _AdaptiveModalRoute({
    required this.builder,
    required this.context,
    this.isBarrierDismissible = true,
    this.contentKey,
  });

  final AdaptiveModalBuilder<T> builder;
  final BuildContext context;
  final bool isBarrierDismissible;
  final GlobalKey? contentKey;

  late final AnimationController _controller;

  /// breakpoint above which a [Dialog] should be displayed instead
  /// of [BottomSheet], if the additional platform condition is met.
  /// superiority/inferiority comparison is allowed because < and > operator
  /// were overloaded in [ScreenSize] .
  final ScreenSize breakpoint = ScreenSize.small;

  @override
  AnimationController createAnimationController() {
    _controller = AnimationController(
      duration: Durations.medium3,
      reverseDuration: Durations.medium1,
      vsync: navigator!,
    );
    return _controller;
  }

  @override
  Duration get transitionDuration => Durations.medium3;

  @override
  Color? get barrierColor => Theme.of(context).colorScheme.scrim.withAlpha(100);

  @override
  bool get barrierDismissible => isBarrierDismissible;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final isWideScreen =
        kIsWeb && ResponsiveService.getScreenSize(context) > breakpoint;

    final double basePadding = 20;
    // viewInsets allows to take into account the virtual keyboard size
    // to offset the content by its height.
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
    final bottom = keyboardPadding > 0
        ? keyboardPadding
        : MediaQuery.of(context).viewPadding.bottom + basePadding;

    return isWideScreen
        ? Dialog(
            constraints: const BoxConstraints(maxWidth: 750),
            child: KeyedSubtree(
                key: contentKey,
                child: Padding(
                  padding: EdgeInsets.all(basePadding),
                  child: builder(
                    context,
                    // this will be used in the caller as "pop" instead of the regular
                    // Navigator.of(context).pop() so we can enforce that the result
                    // matches the T type.
                    ([T? result]) => Navigator.of(context).pop<T>(result),
                  ),
                )),
          )
        : BottomSheet(
            backgroundColor: Theme.of(context).cardTheme.surfaceTintColor,
            animationController: _controller,
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.92),
            showDragHandle: true,
            enableDrag: true,
            dragHandleSize: Size(70, 4),
            // not enforcing the T type return here, this is a "null" case
            onClosing: () => Navigator.of(context).pop(),
            builder: (context) => KeyedSubtree(
              key: contentKey,
              child: ColoredBox(
                color: Theme.of(context).canvasColor,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: basePadding,
                      right: basePadding,
                      top: basePadding,
                      bottom: bottom),
                  child: builder(
                    context,
                    // pop function to be used by the caller so a
                    // T type is returned when popping the route
                    ([T? result]) => Navigator.of(context).pop<T>(result),
                  ),
                ),
              ),
            ),
          );
  }

  // This has to be overriden to adapt the transition to the type of modal
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final isWideScreen =
        kIsWeb && ResponsiveService.getScreenSize(context) > ScreenSize.small;

    if (isWideScreen) {
      // A standard Dialog transition
      return FadeTransition(opacity: animation, child: child);
    }

    return Align(
      alignment: Alignment.bottomCenter,
      // A standard BottomSheet transition
      child: SlideTransition(
        position: Tween<Offset>(
          // Slide transition computes the offset as fraction of the
          // widget's size. So the [begin] point is offset by
          // 100% of the height of the sheet Offset(dx 0, dy 1 * 100% of height). Then, the animation
          // is bringing it back to its actual
          // expected position at  [end] : Offset(0,0)
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

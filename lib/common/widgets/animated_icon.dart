import 'package:flutter/material.dart';

class CustomAnimatedIcon extends StatefulWidget {
  const CustomAnimatedIcon({
    super.key,
    required this.minSize,
    required this.maxSize,
    required this.color,
  });

  final double minSize;
  final double maxSize;
  final Color color;

  @override
  State<CustomAnimatedIcon> createState() => _CustomAnimatedIconState();
}

class _CustomAnimatedIconState extends State<CustomAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController controller = AnimationController(
      duration: const Duration(milliseconds: 400), vsync: this)
    ..repeat(reverse: true);
  late Tween<double> animationSize =
      Tween<double>(begin: widget.minSize, end: widget.maxSize);
  late Tween<double> animationAlpha = Tween<double>(begin: 215, end: 255);

  late final Animation<double> _iconSize = animationSize.animate(controller)
    ..addListener(() => setState(() {}));
  late final Animation<double> _iconAlpha = animationAlpha.animate(controller)
    ..addListener(() => setState(() {}));

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: CustomStaticIcon(
        boxSize: widget.maxSize,
        iconSize: _iconSize.value,
        color: widget.color.withAlpha(_iconAlpha.value.toInt()),
      ),
    );
  }
}

class CustomStaticIcon extends StatelessWidget {
  const CustomStaticIcon({
    super.key,
    required this.boxSize,
    required this.iconSize,
    required this.color,
  });

  final double boxSize;
  final double iconSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: boxSize,
      height: boxSize,
      child: Center(
        child: SizedBox(
          width: iconSize,
          height: iconSize,
          child: FittedBox(
            child: Icon(
              Icons.mic,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/models/themes.dart';
import 'package:mon_stage_en_images/common/widgets/colored_corners.dart';

class MainTitleBackground extends StatelessWidget {
  const MainTitleBackground({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ColoredCorners(
      firstColor: LinearGradient(
        end: const Alignment(0, 0.6),
        begin: const Alignment(0.5, 1.5),
        colors: [
          teacherTheme().colorScheme.primary,
          Colors.white,
        ],
      ),
      secondColor: LinearGradient(
        begin: const Alignment(-0.1, -1),
        end: const Alignment(0, -0.6),
        colors: [
          studentTheme().colorScheme.primary,
          Colors.white10,
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _MainTitle(),
          const SizedBox(height: 50),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _MainTitle extends StatelessWidget {
  const _MainTitle();

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: FractionalOffset.center,
      transform: Matrix4.identity()..rotateZ(-15 * 3.1415927 / 180),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ColoredBox(
            color: studentTheme().colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'STAGE',
                style: TextStyle(
                    fontSize: 40, color: studentTheme().colorScheme.onPrimary),
              ),
            ),
          ),
          ColoredBox(
            color: teacherTheme().colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'IMAGES',
                style: TextStyle(
                    fontSize: 40, color: teacherTheme().colorScheme.onPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

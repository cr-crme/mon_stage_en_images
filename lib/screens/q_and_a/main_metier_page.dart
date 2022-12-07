import 'package:flutter/material.dart';

import '/common/models/student.dart';
import 'widgets/metier_tile.dart';

class MainMetierPage extends StatelessWidget {
  const MainMetierPage({
    super.key,
    required this.student,
    required this.onPageChanged,
  });

  static const routeName = '/main-metier-page';
  final Student? student;
  final Function(int) onPageChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 15),
          if (student != null)
            Text('Résumé des réponses',
                style: Theme.of(context).textTheme.titleLarge),
          if (student != null) const SizedBox(height: 5),
          MetierTile(0, studentId: student?.id, onTap: onPageChanged),
          MetierTile(1, studentId: student?.id, onTap: onPageChanged),
          MetierTile(2, studentId: student?.id, onTap: onPageChanged),
          MetierTile(3, studentId: student?.id, onTap: onPageChanged),
          MetierTile(4, studentId: student?.id, onTap: onPageChanged),
          MetierTile(5, studentId: student?.id, onTap: onPageChanged),
        ],
      ),
    );
  }
}

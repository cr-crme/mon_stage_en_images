import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/models/section.dart';

class MetierInfoCard extends StatelessWidget {
  const MetierInfoCard({super.key, required this.sectionIndex});

  final int sectionIndex;

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: Section.color(sectionIndex).shade900,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(children: [
          Text(Section.description(sectionIndex)),
        ]),
      ),
    );
  }
}

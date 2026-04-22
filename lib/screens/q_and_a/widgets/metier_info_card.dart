import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/models/section.dart';

class MetierInfoCard extends StatelessWidget {
  const MetierInfoCard({super.key, required this.sectionIndex});

  final int sectionIndex;

  @override
  Widget build(BuildContext context) {
    final textColor = Section.color(sectionIndex).computeLuminance() > 0.85
        ? Colors.white
        : Colors.black;

    return Card(
      color: Section.color(sectionIndex).shade300.withAlpha(255),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Icon(
            Section.icon(sectionIndex),
            color: textColor,
            size: MediaQuery.sizeOf(context).height / 28,
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
              child: Text(Section.description(sectionIndex),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textColor,
                      ))),
        ]),
      ),
    );
  }
}

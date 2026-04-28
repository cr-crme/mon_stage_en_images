import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/models/section.dart';
import 'package:mon_stage_en_images/common/providers/database.dart';
import 'package:provider/provider.dart';

class MetierInfoCard extends StatelessWidget {
  const MetierInfoCard({super.key, required this.sectionIndex});

  final int sectionIndex;

  @override
  Widget build(BuildContext context) {
    final userType = Provider.of<Database>(context, listen: false).userType;

    final textColor =
        Section.color(sectionIndex).shade300.computeLuminance() > 0.4
            ? Colors.black
            : Colors.white;

    return Card(
      color: Section.color(sectionIndex).shade300,
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
              child: Text(Section.description(sectionIndex, userType),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textColor, fontWeight: FontWeight.w500))),
        ]),
      ),
    );
  }
}

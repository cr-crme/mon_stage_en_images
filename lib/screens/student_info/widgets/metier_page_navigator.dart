import 'package:flutter/material.dart';

class METIERPageNavigator extends StatelessWidget {
  const METIERPageNavigator(
      {Key? key, required this.selected, required this.onPageChanged})
      : super(key: key);

  final int selected;
  final Function(int) onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primary.withAlpha(70),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _createMETIERButton(context, 'M',
              isSelected: selected == 0, onPressed: () => onPageChanged(0)),
          _createMETIERButton(context, 'É',
              isSelected: selected == 1, onPressed: () => onPageChanged(1)),
          _createMETIERButton(context, 'T',
              isSelected: selected == 2, onPressed: () => onPageChanged(2)),
          _createMETIERButton(context, 'I',
              isSelected: selected == 3, onPressed: () => onPageChanged(3)),
          _createMETIERButton(context, 'E',
              isSelected: selected == 4, onPressed: () => onPageChanged(4)),
          _createMETIERButton(context, 'R',
              isSelected: selected == 5, onPressed: () => onPageChanged(5)),
        ],
      ),
    );
  }

  TextButton _createMETIERButton(BuildContext context, String letter,
      {required isSelected, required onPressed}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
          backgroundColor: isSelected
              ? Theme.of(context).colorScheme.primary.withAlpha(100)
              : null),
      child: Text(
        letter,
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class GroupedRadioButton<T> extends StatelessWidget {
  const GroupedRadioButton({
    Key? key,
    required this.title,
    required this.groupValue,
    required this.onChanged,
    required this.value,
  }) : super(key: key);

  final Widget title;
  final T groupValue;
  final void Function(T?) onChanged;
  final T value;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListTile(
        leading: Radio<T>(
          groupValue: groupValue,
          onChanged: onChanged,
          value: value,
          activeColor: Theme.of(context).colorScheme.secondary,
        ),
        title: Flexible(child: title),
        horizontalTitleGap: 0,
        contentPadding: const EdgeInsets.all(0),
        onTap: () => onChanged(value),
      ),
    );
  }
}

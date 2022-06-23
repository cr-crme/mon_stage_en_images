import 'package:flutter/material.dart';

class METIERPageNavigator extends StatelessWidget {
  const METIERPageNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _createMETIERButton(context, 'M', onPressed: () => null),
          _createMETIERButton(context, 'É', onPressed: () => null),
          _createMETIERButton(context, 'T', onPressed: () => null),
          _createMETIERButton(context, 'I', onPressed: () => null),
          _createMETIERButton(context, 'E', onPressed: () => null),
          _createMETIERButton(context, 'R', onPressed: () => null),
        ],
      ),
    );
  }

  TextButton _createMETIERButton(BuildContext context, String letter,
      {required onPressed}) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        letter,
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}

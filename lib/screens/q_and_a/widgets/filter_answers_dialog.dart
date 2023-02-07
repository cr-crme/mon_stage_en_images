import 'package:flutter/material.dart';

import '/common/models/answer_sort_and_filter.dart';

class FilterAnswerDialog extends StatefulWidget {
  const FilterAnswerDialog({
    super.key,
    required this.currentFilter,
  });

  final AnswerSortAndFilter currentFilter;

  @override
  State<FilterAnswerDialog> createState() => _FilterAnswerDialogState();
}

class _FilterAnswerDialogState extends State<FilterAnswerDialog> {
  late AnswerSorting _sorting = widget.currentFilter.sorting;
  late AnswerFilledFilter _filled = widget.currentFilter.filled;
  late AnswerFromWhomFilter _fromWhom = widget.currentFilter.fromWhomFilter;
  late AnswerContentFilter _content = widget.currentFilter.contentFilter;

  void _selectSorting(value) {
    _sorting = value;
    setState(() {});
  }

  void _selectFilled(value) {
    _filled = value;
    setState(() {});
  }

  void _selectFromWhom(value) {
    _fromWhom = value;
    setState(() {});
  }

  void _selectContent(value) {
    _content = value;
    setState(() {});
  }

  void _finalize(BuildContext context, {bool hasCancelled = false}) {
    if (hasCancelled) {
      Navigator.pop(context);
      return;
    }

    Navigator.pop(
        context,
        AnswerSortAndFilter(
          sorting: _sorting,
          filled: _filled,
          fromWhomFilter: _fromWhom,
          contentFilter: _content,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Triage des réponses'),
            _buildRadioTile<AnswerSorting>(
              text: 'Par date',
              value: AnswerSorting.byDate,
              groupValue: _sorting,
              onTap: _selectSorting,
            ),
            _buildRadioTile<AnswerSorting>(
              text: 'Par élèves',
              value: AnswerSorting.byStudent,
              groupValue: _sorting,
              onTap: _selectSorting,
            ),
            const Divider(),
            const Text('Afficher'),
            _buildRadioTile<AnswerFilledFilter>(
              text: 'Toutes les questions',
              value: AnswerFilledFilter.all,
              groupValue: _filled,
              onTap: _selectFilled,
            ),
            _buildRadioTile<AnswerFilledFilter>(
              text: 'Les questions avec au moins une réponses',
              value: AnswerFilledFilter.withAtLeastOneAnswer,
              groupValue: _filled,
              onTap: _selectFilled,
            ),
            const Divider(),
            const Text('Afficher les réponses de'),
            _buildRadioTile<AnswerFromWhomFilter>(
              text: 'Tous',
              value: AnswerFromWhomFilter.teacherAndStudent,
              groupValue: _fromWhom,
              onTap: _selectFromWhom,
            ),
            _buildRadioTile<AnswerFromWhomFilter>(
              text: 'Élèves uniquement',
              value: AnswerFromWhomFilter.studentOnly,
              groupValue: _fromWhom,
              onTap: _selectFromWhom,
            ),
            _buildRadioTile<AnswerFromWhomFilter>(
              text: 'Professeur uniquement',
              value: AnswerFromWhomFilter.teacherOnly,
              groupValue: _fromWhom,
              onTap: _selectFromWhom,
            ),
            const Divider(),
            const Text('Afficher les réponses contenant'),
            _buildRadioTile<AnswerContentFilter>(
              text: 'Tous',
              value: AnswerContentFilter.textAndPhotos,
              groupValue: _content,
              onTap: _selectContent,
            ),
            _buildRadioTile<AnswerContentFilter>(
              text: 'Texte uniquement',
              value: AnswerContentFilter.textOnly,
              groupValue: _content,
              onTap: _selectContent,
            ),
            _buildRadioTile<AnswerContentFilter>(
              text: 'Photo uniquement',
              value: AnswerContentFilter.photoOnly,
              groupValue: _content,
              onTap: _selectContent,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        OutlinedButton(
          child: Text(
            'Annuler',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary),
          ),
          onPressed: () => _finalize(context, hasCancelled: true),
        ),
        ElevatedButton(
          child: const Text('Enregistrer',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          onPressed: () => _finalize(context),
        ),
      ],
    );
  }

  GestureDetector _buildRadioTile<T>({
    required String text,
    required T value,
    required T groupValue,
    required Function(T) onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap(value),
      child: Row(
        children: [
          Radio<T>(
            value: value,
            groupValue: groupValue,
            onChanged: (_) => onTap(value),
          ),
          Flexible(child: Text(text)),
        ],
      ),
    );
  }
}

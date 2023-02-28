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
  late final AnswerFilledFilter _filled = widget.currentFilter.filled;
  late final List<AnswerFromWhomFilter> _fromWhom =
      widget.currentFilter.fromWhomFilter;
  late final List<AnswerContentFilter> _content =
      widget.currentFilter.contentFilter;

  void _selectSorting(value) {
    _sorting = value;
    setState(() {});
  }

  void _toggleFromWhom(value) {
    if (_fromWhom.contains(value)) {
      _fromWhom.remove(value);
    } else {
      _fromWhom.add(value);
    }
    setState(() {});
  }

  void _toggleContent(value) {
    if (_content.contains(value)) {
      _content.remove(value);
    } else {
      _content.add(value);
    }
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
            const Text(
              'Afficher',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _buildCheckBoxTile(
              text: 'Réponses élèves',
              value: _fromWhom.contains(AnswerFromWhomFilter.studentOnly),
              onTap: (_) => _toggleFromWhom(AnswerFromWhomFilter.studentOnly),
            ),
            _buildCheckBoxTile(
              text: 'Commentaires enseignant.e',
              value: _fromWhom.contains(AnswerFromWhomFilter.teacherOnly),
              onTap: (_) => _toggleFromWhom(AnswerFromWhomFilter.teacherOnly),
            ),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Afficher les réponses contenant',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Flexible(
                  child: _buildCheckBoxTile(
                    text: 'Photo',
                    value: _content.contains(AnswerContentFilter.photoOnly),
                    onTap: (_) => _toggleContent(AnswerContentFilter.photoOnly),
                  ),
                ),
                Flexible(
                  child: _buildCheckBoxTile(
                    text: 'Texte',
                    value: _content.contains(AnswerContentFilter.textOnly),
                    onTap: (_) => _toggleContent(AnswerContentFilter.textOnly),
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Triage des réponses',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: _buildRadioTile<AnswerSorting>(
                    text: 'Par date',
                    value: AnswerSorting.byDate,
                    groupValue: _sorting,
                    onTap: _selectSorting,
                  ),
                ),
                Flexible(
                  child: _buildRadioTile<AnswerSorting>(
                    text: 'Par élève',
                    value: AnswerSorting.byStudent,
                    groupValue: _sorting,
                    onTap: _selectSorting,
                  ),
                ),
              ],
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

  Widget _buildCheckBoxTile({
    required String text,
    required value,
    required Function onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap(value),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (value) => onTap(value),
          ),
          Text(text, maxLines: 1),
        ],
      ),
    );
  }
}

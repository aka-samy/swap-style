import 'package:flutter/material.dart';

class VerificationChecklist extends StatefulWidget {
  final void Function(Map<String, bool> values) onChanged;
  final Map<String, bool>? initialValues;

  const VerificationChecklist({
    super.key,
    required this.onChanged,
    this.initialValues,
  });

  @override
  State<VerificationChecklist> createState() => _VerificationChecklistState();
}

class _VerificationChecklistState extends State<VerificationChecklist> {
  late Map<String, bool> _values;

  static const _items = [
    _ChecklistItem(key: 'washed', label: 'Item has been washed'),
    _ChecklistItem(key: 'noStains', label: 'No stains'),
    _ChecklistItem(key: 'noTears', label: 'No tears or holes'),
    _ChecklistItem(key: 'noDefects', label: 'No other defects'),
    _ChecklistItem(key: 'photosAccurate', label: 'Photos accurately represent the item'),
  ];

  @override
  void initState() {
    super.initState();
    _values = {for (final item in _items) item.key: false};
    if (widget.initialValues != null) {
      _values.addAll(widget.initialValues!);
    }
  }

  void _toggle(String key, bool? value) {
    setState(() => _values[key] = value ?? false);
    widget.onChanged(Map.of(_values));
  }

  bool get allChecked => _values.values.every((v) => v);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Verification Checklist', style: theme.textTheme.titleMedium),
            const Spacer(),
            if (allChecked)
              Chip(
                label: const Text('Verified'),
                backgroundColor: Colors.green.withAlpha(38),
                labelStyle: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.w600),
                avatar: const Icon(Icons.verified, color: Colors.green, size: 16),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Confirm your item meets these conditions before listing',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        ...{for (final item in _items)
          CheckboxListTile(
            value: _values[item.key] ?? false,
            onChanged: (v) => _toggle(item.key, v),
            title: Text(item.label),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          )}.toList(),
      ],
    );
  }
}

class _ChecklistItem {
  final String key;
  final String label;
  const _ChecklistItem({required this.key, required this.label});
}

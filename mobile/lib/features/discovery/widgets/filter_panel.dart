import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/filter_provider.dart';

class FilterPanel extends ConsumerWidget {
  final VoidCallback onApply;

  const FilterPanel({super.key, required this.onApply});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);
    final notifier = ref.read(filterProvider.notifier);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('Filters', style: theme.textTheme.titleLarge),
              const Spacer(),
              TextButton(
                onPressed: () {
                  notifier.reset();
                  onApply();
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),

          // Size filter
          Text('Size', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL'].map((s) {
              final selected = filter.size == s.toLowerCase();
              return ChoiceChip(
                label: Text(s),
                selected: selected,
                onSelected: (_) => notifier.setSize(selected ? null : s.toLowerCase()),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Category filter
          Text('Category', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              'tops', 'bottoms', 'dresses', 'outerwear',
              'shoes', 'accessories', 'activewear', 'formal',
            ].map((c) {
              final selected = filter.category == c;
              return ChoiceChip(
                label: Text(c[0].toUpperCase() + c.substring(1)),
                selected: selected,
                onSelected: (_) => notifier.setCategory(selected ? null : c),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Radius slider
          Row(
            children: [
              Text('Radius', style: theme.textTheme.titleSmall),
              const Spacer(),
              Text('${filter.radiusKm.toInt()} km',
                  style: theme.textTheme.bodySmall),
            ],
          ),
          Slider(
            value: filter.radiusKm,
            min: 1,
            max: 200,
            divisions: 39,
            label: '${filter.radiusKm.toInt()} km',
            onChanged: notifier.setRadius,
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onApply,
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}

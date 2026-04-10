import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/filter_provider.dart';
import '../../../core/models/item.dart';

class FilterPanel extends ConsumerWidget {
  final VoidCallback onApply;

  const FilterPanel({super.key, required this.onApply});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);
    final notifier = ref.read(filterProvider.notifier);
    final theme = Theme.of(context);
    const shoeSizesEu = [35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48];

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
          Text(
            filter.category == 'Shoes' ? 'Shoe Size (EU)' : 'Size',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          if (filter.category == 'Shoes')
            Wrap(
              spacing: 8,
              children: shoeSizesEu.map((s) {
                final selected = filter.shoeSizeEu == s.toDouble();
                return ChoiceChip(
                  label: Text('$s'),
                  selected: selected,
                  onSelected: (_) => notifier.setShoeSizeEu(
                    selected ? null : s.toDouble(),
                  ),
                );
              }).toList(),
            )
          else
            Wrap(
              spacing: 8,
              children: ItemSize.values
                  .map((size) => size.apiValue)
                  .toList()
                  .map((size) {
                final selected = filter.size == size;
                final label = size == 'ONE_SIZE' ? 'ONE SIZE' : size;
                return ChoiceChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (_) => notifier.setSize(selected ? null : size),
                );
              }).toList(),
            ),
          const SizedBox(height: 16),

          // Category filter
          Text('Category', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ItemCategory.values.map((c) {
              final category = c.apiValue;
              final selected = filter.category == category;
              return ChoiceChip(
                label: Text(category),
                selected: selected,
                onSelected: (_) {
                  final newCategory = selected ? null : category;
                  notifier.setCategory(newCategory);
                  if (newCategory == 'Shoes') {
                    notifier.setSize(null);
                  }
                },
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../items/providers/items_provider.dart';
import '../providers/counter_offer_provider.dart';

class ProposeOfferScreen extends ConsumerStatefulWidget {
  final String matchId;
  const ProposeOfferScreen({super.key, required this.matchId});

  @override
  ConsumerState<ProposeOfferScreen> createState() => _ProposeOfferScreenState();
}

class _ProposeOfferScreenState extends ConsumerState<ProposeOfferScreen> {
  final _cashController = TextEditingController();
  final _messageController = TextEditingController();
  final List<String> _selectedItemIds = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(itemsProvider.notifier).loadMyItems());
  }

  @override
  void dispose() {
    _cashController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final cash = double.tryParse(_cashController.text) ?? 0;

    final offer =
        await ref.read(counterOfferProvider(widget.matchId).notifier).propose(
              additionalItemIds: _selectedItemIds,
              monetaryAmount: cash,
              message: _messageController.text.trim().isEmpty
                  ? null
                  : _messageController.text.trim(),
            );

    setState(() => _isSubmitting = false);
    if (mounted) {
      if (offer != null) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Counter-offer sent!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send offer')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Propose Counter-Offer')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Add Extra Items', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildItemPicker(theme),
          const SizedBox(height: 20),

          Text('Cash Adjustment (optional)', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _cashController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              prefixText: '\$ ',
              hintText: '0.00',
            ),
          ),
          const SizedBox(height: 20),

          Text('Message (optional)', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _messageController,
            maxLines: 3,
            maxLength: 300,
            decoration: const InputDecoration(
              hintText: 'Explain your offer...',
            ),
          ),
          const SizedBox(height: 24),

          FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Send Offer'),
          ),
        ],
      ),
    );
  }

  Widget _buildItemPicker(ThemeData theme) {
    final itemState = ref.watch(itemsProvider);
    final items = itemState.items;

    if (itemState.isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (items.isEmpty) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: Text('No items in your closet')),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (ctx, i) {
          final item = items[i];
          final selected = _selectedItemIds.contains(item.id);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (selected) {
                  _selectedItemIds.remove(item.id);
                } else {
                  _selectedItemIds.add(item.id);
                }
              });
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  width: selected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: selected
                    ? theme.colorScheme.primaryContainer
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selected ? Icons.check_circle : Icons.checkroom,
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.brand,
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    item.size.name.toUpperCase(),
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/item.dart';
import '../providers/items_provider.dart';
import '../data/items_repository.dart';
import '../../../core/api/api_client.dart';

final _itemDetailProvider =
    FutureProvider.family<Item, String>((ref, itemId) async {
  final client = ref.watch(apiClientProvider);
  return ItemsRepository(client).getItem(itemId);
});

class EditItemScreen extends ConsumerStatefulWidget {
  final String itemId;
  const EditItemScreen({super.key, required this.itemId});

  @override
  ConsumerState<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends ConsumerState<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brandController;
  late TextEditingController _notesController;

  ItemCategory? _category;
  ItemSize? _size;
  double _shoeSizeEu = 42;
  ItemCondition? _condition;
  bool _isSubmitting = false;
  bool _initialized = false;
  final List<File> _newPhotos = [];
  List<String> _existingPhotoUrls = [];
  final _picker = ImagePicker();
  static const int _maxPhotos = 7;

  static const List<double> _shoeSizesEu = [
    35,
    36,
    37,
    38,
    39,
    40,
    41,
    42,
    43,
    44,
    45,
    46,
    47,
    48,
  ];

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController();
    _notesController = TextEditingController();
  }

  void _populateFields(Item item) {
    if (_initialized) return;
    _initialized = true;
    _brandController.text = item.brand;
    _notesController.text = item.notes ?? '';
    _category = item.category;
    _size = item.size;
    _shoeSizeEu = item.shoeSizeEu ?? 42;
    _condition = item.condition;
    _existingPhotoUrls = item.photos.map((p) => p.url).toList();
  }

  @override
  void dispose() {
    _brandController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final success = await ref.read(itemsProvider.notifier).updateItem(
      widget.itemId,
      {
        'category': _category?.apiValue,
        'brand': _brandController.text.trim(),
        'size': _category == ItemCategory.shoes
            ? ItemSize.oneSize.apiValue
            : _size?.apiValue,
        'shoeSizeEu': _category == ItemCategory.shoes ? _shoeSizeEu : null,
        'condition': _condition?.apiValue,
        'notes': _notesController.text.trim(),
      },
    );

    setState(() => _isSubmitting = false);
    if (mounted) {
      // Upload new photos
      if (success && _newPhotos.isNotEmpty) {
        for (final photo in _newPhotos) {
          await ref.read(itemsProvider.notifier).uploadPhoto(widget.itemId, photo);
        }
      }
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item updated!')),
        );
      }
      Navigator.of(context).pop();
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Item'),
        content: const Text(
          'This will remove the item from your closet and cancel any pending matches. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(itemsProvider.notifier).deleteItem(widget.itemId);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemAsync = ref.watch(_itemDetailProvider(widget.itemId));

    return itemAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Edit Item')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (item) {
        _populateFields(item);
        return _buildForm(context);
      },
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final totalPhotos = _existingPhotoUrls.length + _newPhotos.length;
    if (totalPhotos >= _maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum $_maxPhotos photos allowed')),
      );
      return;
    }
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _newPhotos.add(File(picked.path)));
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline,
                color: Theme.of(context).colorScheme.error),
            onPressed: _delete,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo section
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Existing photos
                  ..._existingPhotoUrls.map((url) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            url,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )),
                  // New photos
                  ..._newPhotos.asMap().entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                entry.value,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => setState(
                                    () => _newPhotos.removeAt(entry.key)),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(Icons.close,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  if (_existingPhotoUrls.length + _newPhotos.length < _maxPhotos)
                    GestureDetector(
                      onTap: _showPhotoOptions,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Theme.of(context).colorScheme.outline),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo,
                                size: 32,
                                color:
                                    Theme.of(context).colorScheme.primary),
                            const SizedBox(height: 4),
                            Text(
                                '${_existingPhotoUrls.length + _newPhotos.length}/$_maxPhotos',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            DropdownButtonFormField<ItemCategory>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: ItemCategory.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.apiValue),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _category = v;
                  if (_category == ItemCategory.shoes) {
                    _size = ItemSize.oneSize;
                  } else if (_size == ItemSize.oneSize) {
                    _size = ItemSize.m;
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),

            if (_category == ItemCategory.shoes)
              DropdownButtonFormField<double>(
                value: _shoeSizeEu,
                decoration: const InputDecoration(labelText: 'Shoe Size (EU)'),
                items: _shoeSizesEu
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.toStringAsFixed(0)),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _shoeSizeEu = v);
                },
              )
            else
              DropdownButtonFormField<ItemSize>(
                value: _size,
                decoration: const InputDecoration(labelText: 'Size'),
                items: ItemSize.values
                    .where((s) => s != ItemSize.oneSize)
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.label),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _size = v),
              ),
            const SizedBox(height: 16),

            DropdownButtonFormField<ItemCondition>(
              value: _condition,
              decoration: const InputDecoration(labelText: 'Condition'),
              items: ItemCondition.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.apiValue),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _condition = v),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Any details about the item...',
              ),
              maxLines: 3,
              maxLength: 500,
            ),
            const SizedBox(height: 24),

            FilledButton(
              onPressed: _isSubmitting ? null : _save,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

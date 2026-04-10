import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/item.dart';
import '../../../core/services/location_service.dart';
import '../providers/items_provider.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _notesController = TextEditingController();
  final _picker = ImagePicker();

  ItemCategory _category = ItemCategory.shirt;
  ItemSize _size = ItemSize.m;
  double _shoeSizeEu = 42;
  ItemCondition _condition = ItemCondition.good;
  bool _isSubmitting = false;
  final List<File> _photos = [];

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
  void dispose() {
    _brandController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    if (_photos.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 photos allowed')),
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
      setState(() => _photos.add(File(picked.path)));
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    // Get real GPS location
    final location = await ref.read(currentLocationProvider.future);

    final item = await ref.read(itemsProvider.notifier).createItem(
        category: _category.apiValue,
          brand: _brandController.text.trim(),
        size: _category == ItemCategory.shoes
          ? ItemSize.oneSize.apiValue
          : _size.apiValue,
        shoeSizeEu: _category == ItemCategory.shoes ? _shoeSizeEu : null,
        condition: _condition.apiValue,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          latitude: location.latitude,
          longitude: location.longitude,
        );

    // Upload photos if item was created
    if (item != null && _photos.isNotEmpty) {
      for (final photo in _photos) {
        await ref.read(itemsProvider.notifier).uploadPhoto(item.id, photo);
      }
    }

    setState(() => _isSubmitting = false);
    if (mounted) {
      if (item != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  ref.read(itemsProvider).error ?? 'Failed to add item')),
        );
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo picker
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ..._photos.asMap().entries.map((entry) => Padding(
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
                                    () => _photos.removeAt(entry.key)),
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
                  if (_photos.length < 5)
                    GestureDetector(
                      onTap: _showPhotoOptions,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: theme.colorScheme.outline),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo,
                                size: 32,
                                color: theme.colorScheme.primary),
                            const SizedBox(height: 4),
                            Text('${_photos.length}/5',
                                style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Category
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

            // Brand
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(labelText: 'Brand'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Brand is required' : null,
            ),
            const SizedBox(height: 16),

            // Size
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
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _size = v);
                },
              ),
            const SizedBox(height: 16),

            // Condition
            DropdownButtonFormField<ItemCondition>(
              value: _condition,
              decoration: const InputDecoration(labelText: 'Condition'),
              items: ItemCondition.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.apiValue),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _condition = v);
              },
            ),
            const SizedBox(height: 16),

            // Notes
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
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('List Item'),
            ),
          ],
        ),
      ),
    );
  }
}

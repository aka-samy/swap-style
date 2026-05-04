import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_error_mapper.dart';
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
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _picker = ImagePicker();

  ItemCategory _category = ItemCategory.shirt;
  ItemSize _size = ItemSize.m;
  double _shoeSizeEu = 42;
  ItemCondition _condition = ItemCondition.good;
  bool _isSubmitting = false;
  final List<File> _photos = [];
  static const int _minPhotos = 1;
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
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draft = prefs.getString('item_draft');
    if (draft != null) {
      try {
        final data = jsonDecode(draft) as Map<String, dynamic>;
        setState(() {
          _titleController.text = data['title'] ?? '';
          _notesController.text = data['notes'] ?? '';
          _category = ItemCategory.values.firstWhere(
            (c) => c.apiValue == data['category'],
            orElse: () => ItemCategory.shirt,
          );
          _size = ItemSize.values.firstWhere(
            (s) => s.apiValue == data['size'],
            orElse: () => ItemSize.m,
          );
          if (data['shoeSizeEu'] != null) {
            _shoeSizeEu = (data['shoeSizeEu'] as num).toDouble();
          }
          _condition = ItemCondition.values.firstWhere(
            (c) => c.apiValue == data['condition'],
            orElse: () => ItemCondition.good,
          );
          final paths = data['photos'] as List<dynamic>?;
          if (paths != null) {
            _photos.addAll(paths.map((p) => File(p.toString())).where((f) => f.existsSync()));
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Draft loaded')),
          );
        }
      } catch (_) {}
    }
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'title': _titleController.text.trim(),
      'notes': _notesController.text.trim(),
      'category': _category.apiValue,
      'size': _size.apiValue,
      'shoeSizeEu': _shoeSizeEu,
      'condition': _condition.apiValue,
      'photos': _photos.map((f) => f.path).toList(),
    };
    await prefs.setString('item_draft', jsonEncode(data));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draft saved! You can resume it later.')),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('item_draft');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    if (_photos.length >= _maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum $_maxPhotos photos allowed')),
      );
      return;
    }
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _photos.add(File(picked.path)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not select photo: $e')),
        );
      }
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
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    if (_photos.length < _minPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Add at least $_minPhotos photo to list this item')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final location = await ref.read(currentLocationProvider.future).timeout(
            const Duration(seconds: 12),
            onTimeout: () => LocationData.fallback,
          );

      final item = await ref.read(itemsProvider.notifier).createItem(
        category: _category.apiValue,
        brand: _titleController.text.trim(),
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

      if (item == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ref.read(itemsProvider).error ?? 'Failed to add item'),
            ),
          );
        }
        return;
      }

      var failedUploads = 0;
      var successfulUploads = 0;
      if (_photos.isNotEmpty) {
        for (final photo in _photos) {
          final ok = await ref.read(itemsProvider.notifier).uploadPhoto(item.id, photo);
          if (ok) {
            successfulUploads++;
          } else {
            failedUploads++;
          }
        }
      }

      if (successfulUploads == 0) {
        await ref.read(itemsProvider.notifier).deleteItem(item.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Listing failed: at least 1 photo must upload successfully.',
              ),
            ),
          );
        }
        return;
      }

      if (!mounted) return;

      if (failedUploads == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Item added, but $failedUploads photo(s) failed to upload.',
            ),
          ),
        );
      }
      ref.read(itemsProvider.notifier).loadMyItems();
      await _clearDraft();
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ApiErrorMapper.toUserMessage(
                e,
                fallback: 'Failed to list item. Please try again.',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photos Section
            Text('Photos', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ..._photos.asMap().entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                entry.value,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () => setState(
                                    () => _photos.removeAt(entry.key)),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(150),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(Icons.close,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  if (_photos.length < _maxPhotos)
                    GestureDetector(
                      onTap: _showPhotoOptions,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 36,
                                color: theme.colorScheme.primary),
                            const SizedBox(height: 8),
                            Text('${_photos.length}/$_maxPhotos',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                )),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Details Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Item Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title / Brand',
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.label_outline),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<ItemCategory>(
                    value: _category,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
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

                  Row(
                    children: [
                      Expanded(
                        child: _category == ItemCategory.shoes
                            ? DropdownButtonFormField<double>(
                                value: _shoeSizeEu,
                                decoration: InputDecoration(
                                  labelText: 'Shoe Size (EU)',
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.straighten),
                                ),
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
                            : DropdownButtonFormField<ItemSize>(
                                value: _size,
                                decoration: InputDecoration(
                                  labelText: 'Size',
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.straighten),
                                ),
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
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<ItemCondition>(
                          value: _condition,
                          decoration: InputDecoration(
                            labelText: 'Condition',
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.diamond_outlined),
                          ),
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'Any details about the item...',
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.description_outlined),
                    ),
                    maxLines: 3,
                    maxLength: 500,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : _saveDraft,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Save Draft', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('List Item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

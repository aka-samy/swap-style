import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/item.dart';
import '../providers/items_provider.dart';
import '../data/items_repository.dart';
import '../../../core/api/api_client.dart';

final _itemDetailProvider =
    FutureProvider.autoDispose.family<Item, String>((ref, itemId) async {
  final client = ref.watch(apiClientProvider);
  return ItemsRepository(client).getItem(itemId);
});

class EditItemScreen extends ConsumerStatefulWidget {
  final String itemId;
  final String? from;
  const EditItemScreen({super.key, required this.itemId, this.from});

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
  List<ItemPhoto> _existingPhotos = [];
  final List<ItemPhoto> _photosToDelete = [];
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
    _existingPhotos = item.photos.toList();
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
      if (success && _photosToDelete.isNotEmpty) {
        for (final photo in _photosToDelete) {
          await ref.read(itemsProvider.notifier).deletePhoto(widget.itemId, photo.id);
        }
      }
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
      if (widget.from != null) {
        context.go(widget.from!);
      } else {
        Navigator.of(context).pop();
      }
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
      if (mounted) {
        if (widget.from != null) {
          context.go(widget.from!);
        } else {
          Navigator.of(context).pop();
        }
      }
    }
  }

  void _deleteExistingPhoto(ItemPhoto photo) {
    if (_existingPhotos.length + _newPhotos.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item must have at least one photo')),
      );
      return;
    }
    
    setState(() {
      _existingPhotos.removeWhere((p) => p.id == photo.id);
      _photosToDelete.add(photo);
    });
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
    final totalPhotos = _existingPhotos.length + _newPhotos.length;
    if (totalPhotos >= _maxPhotos) {
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
        setState(() => _newPhotos.add(File(picked.path)));
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

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            onPressed: _delete,
          ),
        ],
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
                  // Existing photos
                  ..._existingPhotos.map((photo) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                photo.url,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () => _deleteExistingPhoto(photo),
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
                  // New photos
                  ..._newPhotos.asMap().entries.map((entry) => Padding(
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
                                    () => _newPhotos.removeAt(entry.key)),
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
                  if (_existingPhotos.length + _newPhotos.length < _maxPhotos)
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
                            Text(
                                '${_existingPhotos.length + _newPhotos.length}/$_maxPhotos',
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
                    controller: _brandController,
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
                                onChanged: (v) => setState(() => _size = v),
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
                          onChanged: (v) => setState(() => _condition = v),
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

            FilledButton(
              onPressed: _isSubmitting ? null : _save,
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
                  : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

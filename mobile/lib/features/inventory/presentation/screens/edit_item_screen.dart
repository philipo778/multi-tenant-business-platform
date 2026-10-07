import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../businesses/domain/entities/business.dart';
import '../../domain/entities/item.dart';
import '../../domain/item_category_config.dart';
import '../../domain/usecases/update_item.dart';

class EditItemScreen extends StatefulWidget {
  final Business business;
  final Item item;

  const EditItemScreen({
    super.key,
    required this.business,
    required this.item,
  });

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _unitPriceController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _reorderThresholdController;

  late String _selectedCategory;

  bool get _isProduct => widget.item.tracksInventory;

  List<String> get _categories {
    return ItemCategoryConfig.categoriesFor(
      businessCategory: widget.business.category,
      businessSubCategory: widget.business.subCategory,
    );
  }

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.item.name,
    );

    _unitPriceController = TextEditingController(
      text: widget.item.unitPrice.toString(),
    );

    _costPriceController = TextEditingController(
      text: widget.item.costPrice.toString(),
    );

    _stockController = TextEditingController(
      text: widget.item.stockQuantity.toString(),
    );

    _reorderThresholdController = TextEditingController(
      text: widget.item.reorderThreshold.toString(),
    );

    _selectedCategory = widget.item.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitPriceController.dispose();
    _costPriceController.dispose();
    _stockController.dispose();
    _reorderThresholdController.dispose();
    super.dispose();
  }

  Future<void> _updateItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedItem = Item(
      id: widget.item.id,
      businessId: widget.business.id,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      tracksInventory: widget.item.tracksInventory,
      unitPrice: double.parse(
        _unitPriceController.text.trim(),
      ),
      costPrice: double.parse(
        _costPriceController.text.trim(),
      ),
      stockQuantity: _isProduct
          ? double.parse(
        _stockController.text.trim(),
      )
          : 0,
      reorderThreshold: _isProduct
          ? double.parse(
        _reorderThresholdController.text.trim(),
      )
          : 0,
    );

    try {
      await getIt<UpdateItem>()(updatedItem);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item updated successfully'),
        ),
      );

      Navigator.pop(context, updatedItem);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update item: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Edit ${widget.item.name}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.header,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.business.category} • '
                  '${widget.business.location}',
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Item name is required';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Item Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedCategory = value;
                });
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _unitPriceController,
              keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Unit Price',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final price = double.tryParse(
                  value?.trim() ?? '',
                );

                if (price == null || price < 0) {
                  return 'Enter a valid unit price';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _costPriceController,
              keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Cost Price',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final price = double.tryParse(
                  value?.trim() ?? '',
                );

                if (price == null || price < 0) {
                  return 'Enter a valid cost price';
                }

                return null;
              },
            ),

            if (_isProduct) ...[
              const SizedBox(height: 20),

              const Text(
                'Inventory Settings',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.header,
                ),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _stockController,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Current Stock',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final stock = double.tryParse(
                    value?.trim() ?? '',
                  );

                  if (stock == null || stock < 0) {
                    return 'Enter a valid stock quantity';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _reorderThresholdController,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Reorder Threshold',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final threshold = double.tryParse(
                    value?.trim() ?? '',
                  );

                  if (threshold == null ||
                      threshold < 0) {
                    return 'Enter a valid reorder threshold';
                  }

                  return null;
                },
              ),
            ],

            const SizedBox(height: 28),

            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: _updateItem,
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
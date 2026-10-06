import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../businesses/domain/entities/business.dart';
import '../../domain/entities/item.dart';
import '../../domain/item_category_config.dart';
import '../../domain/usecases/create_item.dart';

class AddItemScreen extends StatefulWidget {
  final Business business;

  const AddItemScreen({
    super.key,
    required this.business,
  });

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _reorderThresholdController = TextEditingController();

  late String _selectedCategory;

  String _selectedItemType = 'Product';

  List<String> get _categories {
    return ItemCategoryConfig.categoriesFor(
      widget.business.category,
    );
  }

  bool get _tracksInventory => _selectedItemType == 'Product';

  @override
  void initState() {
    super.initState();

    _selectedCategory = _categories.first;
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

  Future<void> _createItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final item = Item(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      businessId: widget.business.id,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      tracksInventory: _tracksInventory,
      unitPrice: double.parse(
        _unitPriceController.text.trim(),
      ),
      costPrice: double.parse(
        _costPriceController.text.trim(),
      ),
      stockQuantity: _tracksInventory
          ? double.parse(
        _stockController.text.trim(),
      )
          : 0,
      reorderThreshold: _tracksInventory
          ? double.parse(
        _reorderThresholdController.text.trim(),
      )
          : 0,
    );

    try {
      await getIt<CreateItem>()(item);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item created successfully'),
        ),
      );

      Navigator.pop(context, item);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create item: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Add Item to ${widget.business.name}',
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

            // Item Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Item Name',
                hintText: ItemCategoryConfig.nameHintFor(
                  widget.business.category,
                ),
                border: const OutlineInputBorder(),
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

            // Item Category
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

            const SizedBox(height: 20),

            // Item Type
            const Text(
              'Item Type',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.header,
              ),
            ),

            const SizedBox(height: 8),

            SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: 'Product',
                  label: Text('Product'),
                  icon: Icon(Icons.inventory_2_outlined),
                ),
                ButtonSegment<String>(
                  value: 'Service',
                  label: Text('Service'),
                  icon: Icon(Icons.design_services_outlined),
                ),
              ],
              selected: {_selectedItemType},
              onSelectionChanged: (selection) {
                setState(() {
                  _selectedItemType = selection.first;
                });
              },
              style: ButtonStyle(
                foregroundColor:
                WidgetStateProperty.resolveWith(
                      (states) {
                    if (states.contains(
                      WidgetState.selected,
                    )) {
                      return Colors.white;
                    }

                    return AppTheme.header;
                  },
                ),
                backgroundColor:
                WidgetStateProperty.resolveWith(
                      (states) {
                    if (states.contains(
                      WidgetState.selected,
                    )) {
                      return AppTheme.header;
                    }

                    return Colors.transparent;
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Unit Price
            TextFormField(
              controller: _unitPriceController,
              keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Unit Price',
                hintText: 'e.g. 12000',
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

            // Cost Price
            TextFormField(
              controller: _costPriceController,
              keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Cost Price',
                hintText: 'e.g. 9000',
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

            // Inventory Fields
            if (_tracksInventory) ...[
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

              // Opening Stock
              TextFormField(
                controller: _stockController,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Opening Stock',
                  hintText: 'e.g. 50',
                  helperText:
                  'Quantity available when you start tracking this item.',
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

              // Reorder Threshold
              TextFormField(
                controller: _reorderThresholdController,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Reorder Threshold',
                  hintText: 'e.g. 10',
                  helperText:
                  'Alert when stock reaches this level.',
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
                onPressed: _createItem,
                child: const Text(
                  'Create Item',
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
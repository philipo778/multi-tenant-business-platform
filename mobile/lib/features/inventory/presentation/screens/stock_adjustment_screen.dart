import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../businesses/domain/entities/business.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/usecases/create_stock_movement.dart';
import '../../domain/usecases/update_item.dart';

class StockAdjustmentScreen extends StatefulWidget {
  final Business business;
  final Item item;

  const StockAdjustmentScreen({
    super.key,
    required this.business,
    required this.item,
  });

  @override
  State<StockAdjustmentScreen> createState() =>
      _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState
    extends State<StockAdjustmentScreen> {
  final _quantityController = TextEditingController();

  String _selectedType = 'Decrease';

  String _selectedReason = 'Damaged Stock';

  final List<String> _adjustmentReasons = [
    'Damaged Stock',
    'Lost Stock',
    'Physical Count Correction',
    'Expired Stock',
    'Other',
  ];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _quantityController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  double? _parseQuantity() {
    return double.tryParse(
      _quantityController.text.trim(),
    );
  }

  double? _calculateNewStock() {
    final quantity = _parseQuantity();

    if (quantity == null || quantity <= 0) {
      return null;
    }

    final currentStock = widget.item.stockQuantity;

    if (_selectedType == 'Increase') {
      return currentStock + quantity;
    }

    if (quantity > currentStock) {
      return null;
    }

    return currentStock - quantity;
  }

  Future<void> _adjustStock() async {
    final quantity = _parseQuantity();

    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid quantity'),
        ),
      );
      return;
    }

    if (_selectedType == 'Decrease' &&
        quantity > widget.item.stockQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Adjustment cannot reduce stock below zero',
          ),
        ),
      );
      return;
    }

    final stockBefore = widget.item.stockQuantity;
    final stockAfter = _calculateNewStock();

    if (stockAfter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid stock adjustment'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final updatedItem = Item(
      id: widget.item.id,
      businessId: widget.item.businessId,
      name: widget.item.name,
      category: widget.item.category,
      tracksInventory: widget.item.tracksInventory,
      unitPrice: widget.item.unitPrice,
      costPrice: widget.item.costPrice,
      stockQuantity: stockAfter,
      reorderThreshold: widget.item.reorderThreshold,
    );

    final movement = StockMovement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      businessId: widget.item.businessId,
      itemId: widget.item.id,
      type: 'ADJUSTMENT',
      quantity: quantity,
      reason: _selectedReason,
      stockBefore: stockBefore,
      stockAfter: stockAfter,
      createdAt: DateTime.now(),
    );

    try {
      // Update current stock
      await getIt<UpdateItem>()(updatedItem);

      // Record stock movement
      await getIt<CreateStockMovement>()(movement);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Stock adjusted successfully',
          ),
        ),
      );

      Navigator.pop(context, updatedItem);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to adjust stock: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStock = widget.item.stockQuantity;
    final newStock = _calculateNewStock();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Adjustment'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.tune_outlined,
                    size: 50,
                    color: AppTheme.header,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.item.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.header,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Current Stock: '
                        '${currentStock.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppTheme.action,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Adjustment Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.header,
            ),
          ),

          const SizedBox(height: 8),

          SegmentedButton<String>(
            segments: const [
              ButtonSegment<String>(
                value: 'Increase',
                label: Text('Increase'),
                icon: Icon(Icons.add),
              ),
              ButtonSegment<String>(
                value: 'Decrease',
                label: Text('Decrease'),
                icon: Icon(Icons.remove),
              ),
            ],
            selected: {_selectedType},
            onSelectionChanged: (selection) {
              setState(() {
                _selectedType = selection.first;
              });
            },
          ),

          const SizedBox(height: 24),

          TextField(
            controller: _quantityController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Adjustment Quantity',
              hintText: 'e.g. 5',
              border: OutlineInputBorder(),
              prefixIcon: Icon(
                Icons.numbers_outlined,
              ),
            ),
          ),

          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            initialValue: _selectedReason,
            decoration: const InputDecoration(
              labelText: 'Adjustment Reason',
              border: OutlineInputBorder(),
              prefixIcon: Icon(
                Icons.info_outline,
              ),
            ),
            items: _adjustmentReasons.map(
                  (reason) {
                return DropdownMenuItem<String>(
                  value: reason,
                  child: Text(reason),
                );
              },
            ).toList(),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _selectedReason = value;
              });
            },
          ),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'New Stock',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.header,
                    ),
                  ),
                  Text(
                    newStock == null
                        ? 'Invalid'
                        : newStock.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: newStock == null
                          ? Colors.red
                          : AppTheme.action,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _adjustStock,
              icon: _isSaving
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.check),
              label: Text(
                _isSaving
                    ? 'Adjusting...'
                    : 'Save Adjustment',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
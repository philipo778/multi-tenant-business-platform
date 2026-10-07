import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../businesses/domain/entities/business.dart';
import '../../domain/entities/item.dart';
import '../../domain/usecases/update_item.dart';

class RestockItemScreen extends StatefulWidget {
  final Business business;
  final Item item;

  const RestockItemScreen({
    super.key,
    required this.business,
    required this.item,
  });

  @override
  State<RestockItemScreen> createState() => _RestockItemScreenState();
}

class _RestockItemScreenState extends State<RestockItemScreen> {
  final _quantityController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _restock() async {
    final quantityText = _quantityController.text.trim();
    final quantity = double.tryParse(quantityText);

    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid quantity'),
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
      stockQuantity: widget.item.stockQuantity + quantity,
      reorderThreshold: widget.item.reorderThreshold,
    );

    try {
      await getIt<UpdateItem>()(updatedItem);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item restocked successfully'),
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
          content: Text('Failed to restock item: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restock Item'),
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
                    Icons.inventory_2_outlined,
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
                        '${widget.item.stockQuantity.toStringAsFixed(0)}',
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

          TextField(
            controller: _quantityController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Quantity to Add',
              hintText: 'e.g. 50',
              border: OutlineInputBorder(),
              prefixIcon: Icon(
                Icons.add_box_outlined,
              ),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _restock,
              icon: _isSaving
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.add),
              label: Text(
                _isSaving ? 'Restocking...' : 'Restock Item',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
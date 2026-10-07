import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../businesses/domain/entities/business.dart';
import '../../domain/entities/item.dart';
import '../../domain/usecases/delete_item.dart';
import 'edit_item_screen.dart';
import 'restock_item_screen.dart';
import 'stock_adjustment_screen.dart';
import 'stock_movement_history_screen.dart';

class ItemDetailsScreen extends StatelessWidget {
  final Business business;
  final Item item;

  const ItemDetailsScreen({
    super.key,
    required this.business,
    required this.item,
  });

  Future<void> _deleteItem(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: Text(
            'Are you sure you want to delete "${item.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    await getIt<DeleteItem>()(
      business.id,
      item.id,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item deleted successfully'),
      ),
    );

    Navigator.pop(context, true);
  }

  Future<void> _editItem(BuildContext context) async {
    final updatedItem = await Navigator.push<Item>(
      context,
      MaterialPageRoute(
        builder: (context) => EditItemScreen(
          business: business,
          item: item,
        ),
      ),
    );

    if (updatedItem != null && context.mounted) {
      Navigator.pop(context, updatedItem);
    }
  }

  Future<void> _restockItem(BuildContext context) async {
    final updatedItem = await Navigator.push<Item>(
      context,
      MaterialPageRoute(
        builder: (context) => RestockItemScreen(
          business: business,
          item: item,
        ),
      ),
    );

    if (updatedItem != null && context.mounted) {
      Navigator.pop(context, updatedItem);
    }
  }

  Future<void> _adjustStock(BuildContext context) async {
    final updatedItem = await Navigator.push<Item>(
      context,
      MaterialPageRoute(
        builder: (context) => StockAdjustmentScreen(
          business: business,
          item: item,
        ),
      ),
    );

    if (updatedItem != null && context.mounted) {
      Navigator.pop(context, updatedItem);
    }
  }

  void _openStockHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockMovementHistoryScreen(
          business: business,
          item: item,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profitPerUnit = item.unitPrice - item.costPrice;

    final profitMargin = item.unitPrice == 0
        ? 0.0
        : (profitPerUnit / item.unitPrice) * 100;

    final potentialStockProfit =
        item.stockQuantity * profitPerUnit;

    final profitColor = profitPerUnit >= 0
        ? AppTheme.header
        : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        actions: [
          IconButton(
            onPressed: () => _editItem(context),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Item',
          ),
          IconButton(
            onPressed: () => _deleteItem(context),
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete Item',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),

            _buildSectionTitle('Business Information'),
            const SizedBox(height: 8),
            _buildInfoCard([
              _buildInfoRow(
                'Business',
                business.name,
              ),
              _buildInfoRow(
                'Category',
                business.category,
              ),
              _buildInfoRow(
                'Subcategory',
                business.subCategory,
              ),
              _buildInfoRow(
                'Location',
                business.location,
              ),
            ]),

            const SizedBox(height: 20),

            _buildSectionTitle('Item Information'),
            const SizedBox(height: 8),
            _buildInfoCard([
              _buildInfoRow(
                'Name',
                item.name,
              ),
              _buildInfoRow(
                'Type',
                item.tracksInventory
                    ? 'Product'
                    : 'Service',
              ),
              _buildInfoRow(
                'Category',
                item.category,
              ),
            ]),

            const SizedBox(height: 20),

            _buildSectionTitle('Pricing Information'),
            const SizedBox(height: 8),
            _buildInfoCard([
              _buildInfoRow(
                'Selling Price',
                'TZS ${item.unitPrice.toStringAsFixed(0)}',
              ),
              _buildInfoRow(
                'Cost Price',
                'TZS ${item.costPrice.toStringAsFixed(0)}',
              ),
              _buildInfoRow(
                'Profit / Unit',
                'TZS ${profitPerUnit.toStringAsFixed(0)}',
                valueColor: profitColor,
              ),
              _buildInfoRow(
                'Profit Margin',
                '${profitMargin.toStringAsFixed(1)}%',
                valueColor: profitColor,
              ),
            ]),

            if (item.tracksInventory) ...[
              const SizedBox(height: 20),

              _buildSectionTitle('Inventory Information'),
              const SizedBox(height: 8),
              _buildInfoCard([
                _buildInfoRow(
                  'Current Stock',
                  item.stockQuantity.toStringAsFixed(0),
                ),
                _buildInfoRow(
                  'Reorder Threshold',
                  item.reorderThreshold.toStringAsFixed(0),
                ),
                _buildInfoRow(
                  'Potential Stock Profit',
                  'TZS ${potentialStockProfit.toStringAsFixed(0)}',
                  valueColor: profitColor,
                ),
              ]),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: () => _restockItem(context),
                  icon: const Icon(Icons.add_box_outlined),
                  label: const Text('Restock Item'),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => _adjustStock(context),
                  icon: const Icon(Icons.tune_outlined),
                  label: const Text('Adjust Stock'),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => _openStockHistory(context),
                  icon: const Icon(Icons.history_outlined),
                  label: const Text('Stock History'),
                ),
              ),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _editItem(context),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Item'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _deleteItem(context),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Item'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(
                    color: Colors.red,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: AppTheme.header,
              child: Icon(
                Icons.inventory_2_outlined,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.header,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.tracksInventory
                        ? 'Product'
                        : 'Service',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.header,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      String label,
      String value, {
        Color? valueColor,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 24),

            _buildSectionTitle('Business Information'),
            const SizedBox(height: 10),

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

            const SizedBox(height: 22),

            _buildSectionTitle('Item Information'),
            const SizedBox(height: 10),

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

            const SizedBox(height: 22),

            _buildSectionTitle('Pricing Information'),
            const SizedBox(height: 10),

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
              const SizedBox(height: 22),

              _buildSectionTitle('Inventory Information'),
              const SizedBox(height: 10),

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

              _buildPrimaryActionButton(
                label: 'Restock Item',
                icon: Icons.add_box_outlined,
                onPressed: () => _restockItem(context),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildSecondaryActionButton(
                      label: 'Adjust Stock',
                      icon: Icons.tune_outlined,
                      onPressed: () => _adjustStock(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSecondaryActionButton(
                      label: 'Stock History',
                      icon: Icons.history_outlined,
                      onPressed: () => _openStockHistory(context),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 28),

            _buildSectionTitle('Actions'),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildEditButton(
                    onPressed: () => _editItem(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDeleteButton(
                    onPressed: () => _deleteItem(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.06,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.header,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.header,
                  ),
                ),

                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.header.withValues(
                      alpha: 0.08,
                    ),
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.tracksInventory
                        ? 'Product'
                        : 'Service',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.header,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: AppTheme.header,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.border,
        ),
      ),
      child: Column(
        children: children,
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
        vertical: 11,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
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
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ??
                    Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 19,
        ),
        label: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildEditButton({
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(
          Icons.edit_outlined,
          size: 19,
        ),
        label: const Text(
          'Edit Item',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.header,
          side: const BorderSide(
            color: AppTheme.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton({
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(
          Icons.delete_outline,
          size: 19,
        ),
        label: const Text(
          'Delete',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(
            color: Colors.red,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
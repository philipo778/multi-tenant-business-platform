import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../businesses/domain/entities/business.dart';
import '../../domain/entities/item.dart';
import 'restock_item_screen.dart';

class LowStockScreen extends StatelessWidget {
  final Business business;
  final List<Item> items;

  const LowStockScreen({
    super.key,
    required this.business,
    required this.items,
  });

  List<Item> get lowStockItems {
    return items.where((item) {
      return item.tracksInventory &&
          item.stockQuantity <= item.reorderThreshold;
    }).toList();
  }

  String _stockStatus(Item item) {
    if (item.stockQuantity <= 0) {
      return 'Out of Stock';
    }

    return 'Low Stock';
  }

  Color _stockStatusColor(Item item) {
    if (item.stockQuantity <= 0) {
      return Colors.red;
    }

    return AppTheme.action;
  }

  Future<void> _openRestock(
      BuildContext context,
      Item item,
      ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestockItemScreen(
          business: business,
          item: item,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = lowStockItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Low Stock'),
      ),
      body: items.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          return _buildItemCard(
            context,
            item,
          );
        },
      ),
    );
  }

  Widget _buildItemCard(
      BuildContext context,
      Item item,
      ) {
    final statusColor = _stockStatusColor(item);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor,
                  child: const Icon(
                    Icons.warning_amber_outlined,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.header,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.category,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _stockStatus(item),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Stock',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                Text(
                  item.stockQuantity.toStringAsFixed(0),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reorder Threshold',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                Text(
                  item.reorderThreshold.toStringAsFixed(0),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.header,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Selling Price',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'TZS ${item.unitPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.action,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton.icon(
                onPressed: () {
                  _openRestock(
                    context,
                    item,
                  );
                },
                icon: const Icon(
                  Icons.add_box_outlined,
                ),
                label: const Text('Restock Item'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppTheme.header,
            ),
            const SizedBox(height: 20),
            const Text(
              'Stock Levels Are Healthy',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.header,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'No items currently need restocking.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
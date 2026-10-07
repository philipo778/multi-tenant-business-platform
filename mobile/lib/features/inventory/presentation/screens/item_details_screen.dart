import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../businesses/domain/entities/business.dart';
import '../../domain/entities/item.dart';
import '../../domain/usecases/delete_item.dart';
import 'edit_item_screen.dart';


class ItemDetailsScreen extends StatelessWidget {
  final Business business;
  final Item item;

  const ItemDetailsScreen({
    super.key,
    required this.business,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final bool isProduct = item.tracksInventory;

    final bool isLowStock =
        isProduct &&
            item.stockQuantity <= item.reorderThreshold;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () async {
                  final updatedItem =
                  await Navigator.push<Item>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditItemScreen(
                        business: business,
                        item: item,
                      ),
                    ),
                  );

                  if (updatedItem != null &&
                      context.mounted) {
                    Navigator.pop(
                      context,
                      updatedItem,
                    );
                  }
                },
                child: const SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(
                    Icons.edit_outlined,
                    color: AppTheme.header,
                    size: 21,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () async {
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Delete Item'),
                        content: Text(
                          'Are you sure you want to delete '
                              '"${item.name}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldDelete != true || !context.mounted) {
                    return;
                  }

                  try {
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
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete item: $e'),
                      ),
                    );
                  }
                },
                child: const SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 21,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor:
                    AppTheme.header.withValues(alpha: 0.1),
                    child: Icon(
                      isProduct
                          ? Icons.inventory_2_outlined
                          : Icons.design_services_outlined,
                      size: 34,
                      color: AppTheme.header,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.header,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.category,
                    style: const TextStyle(
                      color: AppTheme.action,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle('Business Information'),
          Card(
            child: Column(
              children: [
                _infoTile(
                  icon: Icons.business_outlined,
                  title: 'Business',
                  value: business.name,
                ),
                _infoTile(
                  icon: Icons.category_outlined,
                  title: 'Business Type',
                  value: business.subCategory,
                ),
                _infoTile(
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  value: business.location,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle('Item Information'),
          Card(
            child: Column(
              children: [
                _infoTile(
                  icon: Icons.sell_outlined,
                  title: 'Item Type',
                  value: isProduct ? 'Product' : 'Service',
                ),
                _infoTile(
                  icon: Icons.payments_outlined,
                  title: 'Selling Price',
                  value:
                  'TZS ${item.unitPrice.toStringAsFixed(0)}',
                ),
                _infoTile(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Cost Price',
                  value:
                  'TZS ${item.costPrice.toStringAsFixed(0)}',
                ),
              ],
            ),
          ),
          if (isProduct) ...[
            const SizedBox(height: 16),
            _sectionTitle('Inventory Information'),
            Card(
              child: Column(
                children: [
                  _infoTile(
                    icon: Icons.inventory_2_outlined,
                    title: 'Current Stock',
                    value:
                    item.stockQuantity.toStringAsFixed(0),
                  ),
                  _infoTile(
                    icon: Icons.warning_amber_outlined,
                    title: 'Reorder Threshold',
                    value:
                    item.reorderThreshold.toStringAsFixed(0),
                  ),
                  _infoTile(
                    icon: isLowStock
                        ? Icons.warning_outlined
                        : Icons.check_circle_outline,
                    title: 'Stock Status',
                    value: isLowStock
                        ? 'Low Stock'
                        : 'Stock Available',
                    valueColor: isLowStock
                        ? Colors.red
                        : Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.header,
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.action,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
        ),
      ),
      trailing: Text(
        value,
        textAlign: TextAlign.end,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: valueColor ?? AppTheme.header,
        ),
      ),
    );
  }
}
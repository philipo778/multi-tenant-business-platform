import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/item.dart';

class InventoryAnalyticsScreen extends StatelessWidget {
  final List<Item> items;

  const InventoryAnalyticsScreen({
    super.key,
    required this.items,
  });

  int get totalItems => items.length;

  int get inStockCount {
    return items.where((item) {
      return item.stockQuantity > item.reorderThreshold;
    }).length;
  }

  int get lowStockCount {
    return items.where((item) {
      return item.stockQuantity > 0 &&
          item.stockQuantity <= item.reorderThreshold;
    }).length;
  }

  int get outOfStockCount {
    return items.where((item) {
      return item.stockQuantity <= 0;
    }).length;
  }

  double get inventoryCostValue {
    return items.fold(
      0,
          (total, item) {
        if (!item.tracksInventory) {
          return total;
        }

        return total + (item.stockQuantity * item.costPrice);
      },
    );
  }

  double get potentialSalesValue {
    return items.fold(
      0,
          (total, item) {
        if (!item.tracksInventory) {
          return total;
        }

        return total + (item.stockQuantity * item.unitPrice);
      },
    );
  }

  double get potentialProfit {
    return potentialSalesValue - inventoryCostValue;
  }

  int get itemsNeedingRestock {
    return items.where((item) {
      return item.tracksInventory &&
          item.stockQuantity <= item.reorderThreshold;
    }).length;
  }

  String _formatCurrency(double amount) {
    return 'TZS ${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Analytics'),
      ),
      body: items.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Inventory Overview'),
            const SizedBox(height: 12),
            _buildOverviewGrid(),
            const SizedBox(height: 24),
            _buildSectionTitle('Inventory Value'),
            const SizedBox(height: 12),
            _buildValueCard(
              title: 'Inventory Cost Value',
              value: _formatCurrency(inventoryCostValue),
              icon: Icons.inventory_2_outlined,
            ),
            const SizedBox(height: 10),
            _buildValueCard(
              title: 'Potential Sales Value',
              value: _formatCurrency(potentialSalesValue),
              icon: Icons.point_of_sale_outlined,
            ),
            const SizedBox(height: 10),
            _buildValueCard(
              title: 'Potential Profit',
              value: _formatCurrency(potentialProfit),
              icon: Icons.trending_up_outlined,
              valueColor: potentialProfit >= 0
                  ? AppTheme.header
                  : Colors.red,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Stock Status'),
            const SizedBox(height: 12),
            _buildStockStatusCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Key Insights'),
            const SizedBox(height: 12),
            _buildInsightsCard(),
            const SizedBox(height: 24),
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

  Widget _buildOverviewGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.8,
      children: [
        _buildStatCard(
          title: 'Total Items',
          value: totalItems.toString(),
          icon: Icons.inventory_2_outlined,
        ),
        _buildStatCard(
          title: 'In Stock',
          value: inStockCount.toString(),
          icon: Icons.check_circle_outline,
        ),
        _buildStatCard(
          title: 'Low Stock',
          value: lowStockCount.toString(),
          icon: Icons.warning_amber_outlined,
        ),
        _buildStatCard(
          title: 'Out of Stock',
          value: outOfStockCount.toString(),
          icon: Icons.remove_circle_outline,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.header,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.header,
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

  Widget _buildValueCard({
    required String title,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.header,
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppTheme.action,
          ),
        ),
      ),
    );
  }

  Widget _buildStockStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatusRow(
              'In Stock',
              inStockCount,
              AppTheme.header,
              Icons.check_circle_outline,
            ),
            const Divider(height: 24),
            _buildStatusRow(
              'Low Stock',
              lowStockCount,
              AppTheme.action,
              Icons.warning_amber_outlined,
            ),
            const Divider(height: 24),
            _buildStatusRow(
              'Out of Stock',
              outOfStockCount,
              Colors.red,
              Icons.remove_circle_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(
      String title,
      int count,
      Color color,
      IconData icon,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInsight(
              icon: Icons.warning_amber_outlined,
              text: itemsNeedingRestock > 0
                  ? '$itemsNeedingRestock item(s) need restocking.'
                  : 'No items currently need restocking.',
            ),
            const SizedBox(height: 14),
            _buildInsight(
              icon: Icons.remove_circle_outline,
              text: outOfStockCount > 0
                  ? '$outOfStockCount item(s) are out of stock.'
                  : 'No items are currently out of stock.',
            ),
            const SizedBox(height: 14),
            _buildInsight(
              icon: Icons.trending_up_outlined,
              text:
              'Potential inventory profit is '
                  '${_formatCurrency(potentialProfit)}.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsight({
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppTheme.action,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.analytics_outlined,
              size: 64,
              color: AppTheme.action,
            ),
            const SizedBox(height: 20),
            const Text(
              'No Inventory Data',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.header,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add inventory items to see analytics.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
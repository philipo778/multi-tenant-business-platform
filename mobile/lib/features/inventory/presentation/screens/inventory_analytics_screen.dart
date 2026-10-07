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

  int get productCount {
    return items.where((item) => item.tracksInventory).length;
  }

  int get serviceCount {
    return items.where((item) => !item.tracksInventory).length;
  }

  int get inStockCount {
    return items.where((item) {
      return item.tracksInventory &&
          item.stockQuantity > item.reorderThreshold;
    }).length;
  }

  int get lowStockCount {
    return items.where((item) {
      return item.tracksInventory &&
          item.stockQuantity > 0 &&
          item.stockQuantity <= item.reorderThreshold;
    }).length;
  }

  int get outOfStockCount {
    return items.where((item) {
      return item.tracksInventory &&
          item.stockQuantity <= 0;
    }).length;
  }

  double get inventoryCostValue {
    return items
        .where((item) => item.tracksInventory)
        .fold(
      0,
          (total, item) =>
      total + (item.stockQuantity * item.costPrice),
    );
  }

  double get potentialSalesValue {
    return items
        .where((item) => item.tracksInventory)
        .fold(
      0,
          (total, item) =>
      total + (item.stockQuantity * item.unitPrice),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Analytics'),
      ),
      body: items.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewSection(),

            const SizedBox(height: 24),

            _buildSectionTitle('Inventory Value'),
            const SizedBox(height: 10),

            _buildValueCards(),

            const SizedBox(height: 24),

            _buildSectionTitle('Stock Status'),
            const SizedBox(height: 10),

            _buildStockStatus(),

            const SizedBox(height: 24),

            _buildSectionTitle('Key Insights'),
            const SizedBox(height: 10),

            _buildKeyInsights(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inventory Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.header,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'A quick summary of your current inventory.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                value: totalItems.toString(),
                label: 'Items',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildOverviewCard(
                value: productCount.toString(),
                label: 'Products',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildOverviewCard(
                value: serviceCount.toString(),
                label: 'Services',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildOverviewCard(
                value: itemsNeedingRestock.toString(),
                label: 'Low Stock',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard({
    required String value,
    required String label,
  }) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.header,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueCards() {
    return Column(
      children: [
        _buildValueCard(
          title: 'Inventory Cost Value',
          value: inventoryCostValue,
          description: 'Estimated cost of current stock.',
          valueColor: AppTheme.header,
        ),
        const SizedBox(height: 12),
        _buildValueCard(
          title: 'Potential Sales Value',
          value: potentialSalesValue,
          description:
          'Estimated revenue if current stock is sold.',
          valueColor: AppTheme.action,
        ),
        const SizedBox(height: 12),
        _buildValueCard(
          title: 'Potential Profit',
          value: potentialProfit,
          description:
          'Estimated profit from current stock.',
          valueColor:
          potentialProfit >= 0
              ? AppTheme.header
              : Colors.red,
        ),
      ],
    );
  }

  Widget _buildValueCard({
    required String title,
    required double value,
    required String description,
    required Color valueColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.header,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'TZS ${value.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatusRow(
            label: 'In Stock',
            value: inStockCount,
            color: AppTheme.header,
          ),
          const Divider(height: 24),
          _buildStatusRow(
            label: 'Low Stock',
            value: lowStockCount,
            color: AppTheme.action,
          ),
          const Divider(height: 24),
          _buildStatusRow(
            label: 'Out of Stock',
            value: outOfStockCount,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required String label,
    required int value,
    required Color color,
  }) {
    return Row(
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
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildKeyInsights() {
    return Column(
      children: [
        _buildInsightCard(
          title: 'Products',
          value: '$productCount products',
          description:
          '$productCount items are currently tracked as products.',
        ),
        const SizedBox(height: 10),
        _buildInsightCard(
          title: 'Restocking',
          value: '$itemsNeedingRestock items',
          description:
          'These items are at or below their reorder threshold.',
        ),
        const SizedBox(height: 10),
        _buildInsightCard(
          title: 'Potential Profit',
          value:
          'TZS ${potentialProfit.toStringAsFixed(0)}',
          description:
          'Estimated profit based on current stock and prices.',
        ),
      ],
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String value,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.header,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            const Text(
              'No Inventory Data',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: AppTheme.header,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add inventory items to see analytics.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
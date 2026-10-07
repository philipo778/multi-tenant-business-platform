import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../businesses/domain/entities/business.dart';
import '../../domain/entities/item.dart';
import '../../domain/usecases/get_items.dart';
import 'add_item_screen.dart';
import 'item_details_screen.dart';

class InventoryScreen extends StatefulWidget {
  final Business business;

  const InventoryScreen({
    super.key,
    required this.business,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final GetItems _getItems = getIt<GetItems>();

  List<Item> items = [];
  bool isLoading = true;

  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final result = await _getItems(
      widget.business.id,
    );

    if (!mounted) return;

    setState(() {
      items = result;
      isLoading = false;
    });
  }

  Future<void> _openAddItem() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(
          business: widget.business,
        ),
      ),
    );

    await _loadItems();
  }

  Future<void> _openItemDetails(Item item) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailsScreen(
          business: widget.business,
          item: item,
        ),
      ),
    );

    if (result != null && mounted) {
      await _loadItems();
    }
  }

  String _stockStatus(Item item) {
    if (item.stockQuantity <= 0) {
      return 'Out of Stock';
    }

    if (item.stockQuantity <= item.reorderThreshold) {
      return 'Low Stock';
    }

    return 'In Stock';
  }

  Color _stockStatusColor(Item item) {
    if (item.stockQuantity <= 0) {
      return Colors.red;
    }

    if (item.stockQuantity <= item.reorderThreshold) {
      return AppTheme.action;
    }

    return AppTheme.header;
  }

  List<Item> _filteredItems() {
    switch (_selectedFilter) {
      case 'In Stock':
        return items.where((item) {
          return item.stockQuantity > item.reorderThreshold;
        }).toList();

      case 'Low Stock':
        return items.where((item) {
          return item.stockQuantity > 0 &&
              item.stockQuantity <= item.reorderThreshold;
        }).toList();

      case 'Out of Stock':
        return items.where((item) {
          return item.stockQuantity <= 0;
        }).toList();

      default:
        return items;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            onPressed: _openAddItem,
            icon: const Icon(Icons.add),
            tooltip: 'Add Item',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : items.isEmpty
          ? _buildEmptyState()
          : Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: filteredItems.isEmpty
                ? _buildNoFilterResults()
                : _buildItemList(filteredItems),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddItem,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        8,
      ),
      child: Row(
        children: [
          _buildFilterButton('All'),
          const SizedBox(width: 8),
          _buildFilterButton('In Stock'),
          const SizedBox(width: 8),
          _buildFilterButton('Low Stock'),
          const SizedBox(width: 8),
          _buildFilterButton('Out of Stock'),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String filter) {
    final isSelected = _selectedFilter == filter;

    return ChoiceChip(
      label: Text(filter),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = filter;
        });
      },
      selectedColor: AppTheme.header,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.header,
        fontWeight: FontWeight.w600,
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
            const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppTheme.action,
            ),
            const SizedBox(height: 20),
            const Text(
              'No items found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.header,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No inventory items have been added to '
                  '${widget.business.name} yet.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _openAddItem,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoFilterResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.filter_list_off,
              size: 56,
              color: AppTheme.action,
            ),
            const SizedBox(height: 16),
            Text(
              'No $_selectedFilter items',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.header,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'There are no items matching this filter.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemList(List<Item> filteredItems) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        100,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];

        final status = _stockStatus(item);
        final statusColor = _stockStatusColor(item);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            onTap: () {
              _openItemDetails(item);
            },
            leading: CircleAvatar(
              backgroundColor: AppTheme.header,
              child: const Icon(
                Icons.inventory_2_outlined,
                color: Colors.white,
              ),
            ),
            title: Text(
              item.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.header,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.category} • '
                        'Stock: ${item.stockQuantity.toStringAsFixed(0)}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            trailing: Text(
              'TZS ${item.unitPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.action,
              ),
            ),
          ),
        );
      },
    );
  }
}
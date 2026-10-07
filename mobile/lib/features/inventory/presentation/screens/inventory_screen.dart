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

  final TextEditingController _searchController =
  TextEditingController();

  List<Item> items = [];

  bool isLoading = true;

  String _selectedFilter = 'All';

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery =
            _searchController.text.trim().toLowerCase();
      });
    });

    _loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  int _inStockCount() {
    return items.where((item) {
      return item.stockQuantity > item.reorderThreshold;
    }).length;
  }

  int _lowStockCount() {
    return items.where((item) {
      return item.stockQuantity > 0 &&
          item.stockQuantity <= item.reorderThreshold;
    }).length;
  }

  int _outOfStockCount() {
    return items.where((item) {
      return item.stockQuantity <= 0;
    }).length;
  }

  double _inventoryValue() {
    return items.fold(
      0,
          (total, item) {
        if (!item.tracksInventory) {
          return total;
        }

        return total +
            (item.stockQuantity * item.costPrice);
      },
    );
  }

  List<Item> _filteredItems() {
    Iterable<Item> result = items;

    switch (_selectedFilter) {
      case 'In Stock':
        result = result.where((item) {
          return item.stockQuantity >
              item.reorderThreshold;
        });
        break;

      case 'Low Stock':
        result = result.where((item) {
          return item.stockQuantity > 0 &&
              item.stockQuantity <=
                  item.reorderThreshold;
        });
        break;

      case 'Out of Stock':
        result = result.where((item) {
          return item.stockQuantity <= 0;
        });
        break;
    }

    if (_searchQuery.isNotEmpty) {
      result = result.where((item) {
        final name = item.name.toLowerCase();
        final category =
        item.category.toLowerCase();

        return name.contains(_searchQuery) ||
            category.contains(_searchQuery);
      });
    }

    return result.toList();
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
          _buildSummary(),
          _buildSearchField(),
          _buildFilterBar(),
          Expanded(
            child: filteredItems.isEmpty
                ? _buildNoResults()
                : _buildItemList(
              filteredItems,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddItem,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        0,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total',
                  value: items.length.toString(),
                  icon: Icons.inventory_2_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryCard(
                  title: 'In Stock',
                  value: _inStockCount().toString(),
                  icon: Icons.check_circle_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Low Stock',
                  value: _lowStockCount().toString(),
                  icon: Icons.warning_amber_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Out of Stock',
                  value: _outOfStockCount().toString(),
                  icon: Icons.remove_circle_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildInventoryValueCard(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
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
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
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

  Widget _buildInventoryValueCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppTheme.action,
              size: 30,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Inventory Value',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'TZS ${_inventoryValue().toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.header,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Based on cost price',
                    style: TextStyle(
                      fontSize: 11,
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

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        8,
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search items or categories...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            onPressed: () {
              _searchController.clear();
            },
            icon: const Icon(Icons.clear),
          )
              : null,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
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
    final isSelected =
        _selectedFilter == filter;

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
        color: isSelected
            ? Colors.white
            : AppTheme.header,
        fontWeight: FontWeight.w600,
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

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 56,
              color: AppTheme.action,
            ),
            const SizedBox(height: 16),
            const Text(
              'No matching items',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.header,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a different search term or filter.',
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
        final statusColor =
        _stockStatusColor(item);

        return Card(
          margin:
          const EdgeInsets.only(bottom: 12),
          child: ListTile(
            onTap: () {
              _openItemDetails(item);
            },
            leading: const CircleAvatar(
              backgroundColor: AppTheme.header,
              child: Icon(
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
              padding:
              const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.category} • '
                        'Stock: '
                        '${item.stockQuantity.toStringAsFixed(0)}',
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
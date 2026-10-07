import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../businesses/domain/entities/business.dart';
import '../../domain/entities/item.dart';
import '../../domain/usecases/delete_item.dart';
import '../../domain/usecases/get_items.dart';
import 'add_item_screen.dart';
import 'inventory_analytics_screen.dart';
import 'item_details_screen.dart';
import 'low_stock_screen.dart';

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
  final DeleteItem _deleteItem = getIt<DeleteItem>();

  List<Item> items = [];

  bool isLoading = true;

  String searchQuery = '';
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      isLoading = true;
    });

    final result = await _getItems(widget.business.id);

    if (!mounted) return;

    setState(() {
      items = result;
      isLoading = false;
    });
  }

  List<Item> get filteredItems {
    return items.where((item) {
      final matchesSearch = item.name
          .toLowerCase()
          .contains(searchQuery.toLowerCase());

      bool matchesFilter = true;

      switch (selectedFilter) {
        case 'Products':
          matchesFilter = item.tracksInventory;
          break;

        case 'Services':
          matchesFilter = !item.tracksInventory;
          break;

        case 'Low Stock':
          matchesFilter = item.tracksInventory &&
              item.stockQuantity <= item.reorderThreshold;
          break;

        case 'Out of Stock':
          matchesFilter =
              item.tracksInventory && item.stockQuantity <= 0;
          break;

        case 'All':
          matchesFilter = true;
          break;
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  int get totalItems {
    return items.length;
  }

  int get productCount {
    return items.where((item) => item.tracksInventory).length;
  }

  int get serviceCount {
    return items.where((item) => !item.tracksInventory).length;
  }

  int get lowStockCount {
    return items.where((item) {
      return item.tracksInventory &&
          item.stockQuantity <= item.reorderThreshold;
    }).length;
  }

  int get outOfStockCount {
    return items.where((item) {
      return item.tracksInventory && item.stockQuantity <= 0;
    }).length;
  }

  Future<void> _openAddItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(
          business: widget.business,
        ),
      ),
    );

    if (result != null) {
      await _loadItems();
    }
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

    if (result != null) {
      await _loadItems();
    }
  }

  Future<void> _openAnalytics() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InventoryAnalyticsScreen(
          items: items,
        ),
      ),
    );
  }

  Future<void> _openLowStock() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LowStockScreen(
          business: widget.business,
          items: items,
        ),
      ),
    );

    await _loadItems();
  }

  Future<void> _deleteSelectedItem(Item item) async {
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
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await _deleteItem(
      widget.business.id,
      item.id,
    );

    if (!mounted) return;

    await _loadItems();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item deleted successfully'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            onPressed: _openLowStock,
            icon: const Icon(
              Icons.warning_amber_outlined,
            ),
            tooltip: 'Low Stock',
          ),
          IconButton(
            onPressed: _openAnalytics,
            icon: const Icon(
              Icons.analytics_outlined,
            ),
            tooltip: 'Inventory Analytics',
          ),
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
          : RefreshIndicator(
        onRefresh: _loadItems,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBusinessHeader(),
            const SizedBox(height: 16),
            _buildSummaryCards(),
            const SizedBox(height: 20),
            _buildSearchField(),
            const SizedBox(height: 12),
            _buildFilterChips(),
            const SizedBox(height: 20),
            if (visibleItems.isEmpty)
              _buildEmptyState()
            else
              ...visibleItems.map(
                    (item) => _buildItemCard(item),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddItem,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBusinessHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.header,
              child: const Icon(
                Icons.storefront_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.business.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.header,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.business.category} • '
                        '${widget.business.subCategory}',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.business.location,
                    style: const TextStyle(
                      fontSize: 12,
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

  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Total Items',
                value: totalItems.toString(),
                icon: Icons.inventory_2_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Products',
                value: productCount.toString(),
                icon: Icons.shopping_bag_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Services',
                value: serviceCount.toString(),
                icon: Icons.miscellaneous_services_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Low Stock',
                value: lowStockCount.toString(),
                icon: Icons.warning_amber_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.header,
              child: Icon(
                icon,
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
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.header,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
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
    return TextField(
      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Search items...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
          onPressed: () {
            setState(() {
              searchQuery = '';
            });
          },
          icon: const Icon(Icons.clear),
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      'All',
      'Products',
      'Services',
      'Low Stock',
      'Out of Stock',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected =
              selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  selectedFilter = filter;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildItemCard(Item item) {
    final isLowStock = item.tracksInventory &&
        item.stockQuantity <= item.reorderThreshold;

    final isOutOfStock = item.tracksInventory &&
        item.stockQuantity <= 0;

    final statusColor = isOutOfStock
        ? Colors.red
        : isLowStock
        ? AppTheme.action
        : AppTheme.header;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _openItemDetails(item);
        },
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
                    child: Icon(
                      item.tracksInventory
                          ? Icons.inventory_2_outlined
                          : Icons.miscellaneous_services_outlined,
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
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteSelectedItem(item);
                      }
                    },
                    itemBuilder: (context) {
                      return const [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              if (item.tracksInventory) ...[
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
                        fontSize: 16,
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
                      'Reorder At',
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
              ],
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
              if (item.tracksInventory) ...[
                const SizedBox(height: 12),
                _buildStockStatus(
                  item,
                  statusColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockStatus(
      Item item,
      Color statusColor,
      ) {
    String text;

    if (item.stockQuantity <= 0) {
      text = 'Out of Stock';
    } else if (item.stockQuantity <=
        item.reorderThreshold) {
      text = 'Low Stock';
    } else {
      text = 'Stock Healthy';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            item.stockQuantity <= item.reorderThreshold
                ? Icons.warning_amber_outlined
                : Icons.check_circle_outline,
            size: 18,
            color: statusColor,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearch =
        searchQuery.trim().isNotEmpty;

    final hasFilter =
        selectedFilter != 'All';

    if (hasSearch || hasFilter) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 60,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.search_off_outlined,
              size: 64,
              color: AppTheme.action,
            ),
            const SizedBox(height: 20),
            const Text(
              'No Items Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.header,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try another search or filter.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 60,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppTheme.action,
          ),
          const SizedBox(height: 20),
          const Text(
            'No Inventory Items',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.header,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start by adding your first product or service.',
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
    );
  }
}
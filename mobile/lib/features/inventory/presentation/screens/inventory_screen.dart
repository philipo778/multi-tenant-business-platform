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
      final query = searchQuery.trim().toLowerCase();

      final matchesSearch = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query);

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
              item.stockQuantity > 0 &&
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
          item.stockQuantity > 0 &&
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
          if (lowStockCount > 0 || outOfStockCount > 0)
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
            tooltip: 'Analytics',
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
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            90,
          ),
          children: [
            _buildBusinessHeader(),

            const SizedBox(height: 16),

            _buildCompactSummary(),

            const SizedBox(height: 18),

            _buildSearchField(),

            const SizedBox(height: 12),

            _buildFilterChips(),

            const SizedBox(height: 18),

            if (visibleItems.isEmpty)
              _buildEmptyState()
            else
              _buildItemsList(visibleItems),
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
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.business.name,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.header,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${widget.business.category} • '
                    '${widget.business.subCategory}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Text(
          '$totalItems items',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.header,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactSummary() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.header,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryValue(
              value: totalItems.toString(),
              label: 'Items',
            ),
          ),
          _buildSummaryDivider(),
          Expanded(
            child: _buildSummaryValue(
              value: productCount.toString(),
              label: 'Products',
            ),
          ),
          _buildSummaryDivider(),
          Expanded(
            child: _buildSummaryValue(
              value: serviceCount.toString(),
              label: 'Services',
            ),
          ),
          _buildSummaryDivider(),
          Expanded(
            child: _buildSummaryValue(
              value: lowStockCount.toString(),
              label: 'Low Stock',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryValue({
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryDivider() {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white24,
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
        hintText: 'Search inventory...',
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
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    const filters = [
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
          final isSelected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
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

  Widget _buildItemsList(List<Item> visibleItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Items',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.header,
              ),
            ),
            Text(
              '${visibleItems.length} shown',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.border,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (int index = 0;
              index < visibleItems.length;
              index++) ...[
                _buildCompactItem(
                  visibleItems[index],
                ),
                if (index != visibleItems.length - 1)
                  const Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactItem(Item item) {
    final bool isOutOfStock =
        item.tracksInventory && item.stockQuantity <= 0;

    final bool isLowStock =
        item.tracksInventory &&
            item.stockQuantity > 0 &&
            item.stockQuantity <= item.reorderThreshold;

    final Color statusColor = isOutOfStock
        ? Colors.red
        : isLowStock
        ? AppTheme.action
        : AppTheme.header;

    return Material(
      color: AppTheme.background,
      child: InkWell(
        onTap: () {
          _openItemDetails(item);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.header,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (item.tracksInventory)
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Stock ${item.stockQuantity.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'TZS ${item.unitPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.action,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              else
                const Text(
                  'Service',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteSelectedItem(item);
                  }
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
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
            const Text(
              'No items found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.header,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try another search or filter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
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
          const Text(
            'No inventory items',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.header,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first product or service.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: _openAddItem,
            child: const Text('Add Item'),
          ),
        ],
      ),
    );
  }
}
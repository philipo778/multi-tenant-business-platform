import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/item.dart';
import '../../domain/usecases/delete_item.dart';
import '../../domain/usecases/get_items.dart';
import 'add_item_screen.dart';
import 'inventory_analytics_screen.dart';
import 'item_details_screen.dart';
import 'low_stock_screen.dart';

class InventoryScreen extends StatefulWidget {
  final dynamic business;

  const InventoryScreen({
    super.key,
    required this.business,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late Future<List<Item>> _itemsFuture;

  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    _itemsFuture = getIt<GetItems>()(
      widget.business.id,
    );
  }

  Future<void> _refreshItems() async {
    setState(() {
      _loadItems();
    });

    await _itemsFuture;
  }

  List<Item> _filterItems(List<Item> items) {
    final query = _searchQuery.trim().toLowerCase();

    return items.where((item) {
      final matchesSearch =
          query.isEmpty ||
              item.name.toLowerCase().contains(query) ||
              item.category.toLowerCase().contains(query);

      if (!matchesSearch) {
        return false;
      }

      switch (_selectedFilter) {
        case 'Products':
          return item.tracksInventory;

        case 'Services':
          return !item.tracksInventory;

        case 'Low Stock':
          return item.tracksInventory &&
              item.stockQuantity > 0 &&
              item.stockQuantity <= item.reorderThreshold;

        case 'Out of Stock':
          return item.tracksInventory &&
              item.stockQuantity <= 0;

        case 'All':
        default:
          return true;
      }
    }).toList();
  }

  int _productCount(List<Item> items) {
    return items.where((item) => item.tracksInventory).length;
  }

  int _serviceCount(List<Item> items) {
    return items.where((item) => !item.tracksInventory).length;
  }

  int _lowStockCount(List<Item> items) {
    return items.where((item) {
      return item.tracksInventory &&
          item.stockQuantity > 0 &&
          item.stockQuantity <= item.reorderThreshold;
    }).length;
  }

  int _outOfStockCount(List<Item> items) {
    return items.where((item) {
      return item.tracksInventory &&
          item.stockQuantity <= 0;
    }).length;
  }

  Future<void> _openAddItem() async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => AddItemScreen(
          business: widget.business,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (result is Item) {
      _refreshItems();
    }
  }

  Future<void> _openItemDetails(Item item) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetailsScreen(
          business: widget.business,
          item: item,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (result == true || result is Item) {
      _refreshItems();
    }
  }

  Future<void> _deleteItem(Item item) async {
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
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await getIt<DeleteItem>()(
      widget.business.id,
      item.id,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item deleted successfully'),
      ),
    );

    _refreshItems();
  }

  Future<void> _openLowStock() async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => LowStockScreen(
          business: widget.business,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (result == true || result is Item) {
      _refreshItems();
    } else {
      _refreshItems();
    }
  }

  Future<void> _openAnalytics(List<Item> items) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InventoryAnalyticsScreen(
          items: items,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          FutureBuilder<List<Item>>(
            future: _itemsFuture,
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              final lowStockCount = _lowStockCount(items);
              final outOfStockCount = _outOfStockCount(items);

              if (lowStockCount == 0 && outOfStockCount == 0) {
                return const SizedBox.shrink();
              }

              return IconButton(
                onPressed: _openLowStock,
                tooltip: 'Low Stock',
                icon: const Icon(
                  Icons.warning_amber_rounded,
                ),
              );
            },
          ),
          FutureBuilder<List<Item>>(
            future: _itemsFuture,
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];

              return IconButton(
                onPressed: items.isEmpty
                    ? null
                    : () => _openAnalytics(items),
                tooltip: 'Analytics',
                icon: const Icon(
                  Icons.analytics_outlined,
                ),
              );
            },
          ),
          IconButton(
            onPressed: _openAddItem,
            tooltip: 'Add Item',
            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddItem,
        backgroundColor: AppTheme.action,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Item>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState();
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return _buildEmptyState();
          }

          final filteredItems = _filterItems(items);

          return RefreshIndicator(
            onRefresh: _refreshItems,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                100,
              ),
              children: [
                _buildBusinessHeader(),
                const SizedBox(height: 16),
                _buildSummary(items),
                const SizedBox(height: 16),
                _buildSearch(),
                const SizedBox(height: 12),
                _buildFilters(items),
                const SizedBox(height: 16),
                if (filteredItems.isEmpty)
                  _buildNoResults()
                else
                  ...filteredItems.map(
                        (item) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: _buildItemCard(item),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBusinessHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.header,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.storefront_outlined,
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
                  widget.business.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.business.subCategory,
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.75,
                    ),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(List<Item> items) {
    final products = _productCount(items);
    final services = _serviceCount(items);
    final lowStock = _lowStockCount(items);
    final outOfStock = _outOfStockCount(items);

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            value: items.length.toString(),
            label: 'Total',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            value: products.toString(),
            label: 'Products',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            value: services.toString(),
            label: 'Services',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            value: (lowStock + outOfStock).toString(),
            label: 'Alerts',
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.border,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: AppTheme.header,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Search items...',
        prefixIcon: const Icon(
          Icons.search,
        ),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
          onPressed: () {
            setState(() {
              _searchQuery = '';
            });
          },
          icon: const Icon(
            Icons.clear,
          ),
        ),
        filled: true,
        fillColor: AppTheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.header,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(List<Item> items) {
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
          final selected =
              _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(
              right: 8,
            ),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              selectedColor: AppTheme.header,
              backgroundColor: AppTheme.background,
              side: const BorderSide(
                color: AppTheme.border,
              ),
              labelStyle: TextStyle(
                color: selected
                    ? Colors.white
                    : AppTheme.header,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildItemCard(Item item) {
    final isLowStock =
        item.tracksInventory &&
            item.stockQuantity > 0 &&
            item.stockQuantity <=
                item.reorderThreshold;

    final isOutOfStock =
        item.tracksInventory &&
            item.stockQuantity <= 0;

    return InkWell(
      onTap: () => _openItemDetails(item),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.header.withValues(
                  alpha: 0.08,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.tracksInventory
                    ? Icons.inventory_2_outlined
                    : Icons.miscellaneous_services_outlined,
                color: AppTheme.header,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.header,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (item.tracksInventory)
                    Text(
                      'Stock: ${item.stockQuantity.toStringAsFixed(0)}  •  TZS ${item.unitPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isOutOfStock
                            ? Colors.red
                            : isLowStock
                            ? AppTheme.action
                            : AppTheme.header,
                      ),
                    )
                  else
                    Text(
                      'Service  •  TZS ${item.unitPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.header,
                      ),
                    ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteItem(item);
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem<String>(
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _refreshItems,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height:
            MediaQuery.of(context).size.height *
                0.28,
          ),
          const Icon(
            Icons.inventory_2_outlined,
            size: 70,
            color: AppTheme.header,
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'No Inventory Items',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: AppTheme.header,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 32,
            ),
            child: Text(
              'Start adding products or services to manage your inventory.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: _openAddItem,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.header,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 60,
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 58,
            color: AppTheme.header.withValues(
              alpha: 0.45,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No Matching Items',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: AppTheme.header,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try changing your search or filter.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to Load Inventory',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.header,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Something went wrong while loading your inventory.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loadItems();
                });
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
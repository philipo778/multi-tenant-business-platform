import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../businesses/domain/entities/business.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/usecases/get_item_stock_movements.dart';

class StockMovementHistoryScreen extends StatefulWidget {
  final Business business;
  final Item item;

  const StockMovementHistoryScreen({
    super.key,
    required this.business,
    required this.item,
  });

  @override
  State<StockMovementHistoryScreen> createState() =>
      _StockMovementHistoryScreenState();
}

class _StockMovementHistoryScreenState
    extends State<StockMovementHistoryScreen> {
  final GetItemStockMovements _getItemStockMovements =
  getIt<GetItemStockMovements>();

  List<StockMovement> movements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovements();
  }

  Future<void> _loadMovements() async {
    final result = await _getItemStockMovements(
      widget.business.id,
      widget.item.id,
    );

    if (!mounted) return;

    setState(() {
      movements = result.reversed.toList();
      isLoading = false;
    });
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year at $hour:$minute';
  }

  IconData _movementIcon(String type) {
    switch (type) {
      case 'RESTOCK':
        return Icons.add_box_outlined;
      case 'ADJUSTMENT':
        return Icons.tune_outlined;
      default:
        return Icons.swap_vert;
    }
  }

  Color _movementColor(String type) {
    switch (type) {
      case 'RESTOCK':
        return AppTheme.header;
      case 'ADJUSTMENT':
        return AppTheme.action;
      default:
        return Colors.grey;
    }
  }

  String _quantityText(StockMovement movement) {
    final difference =
        movement.stockAfter - movement.stockBefore;

    final sign = difference >= 0 ? '+' : '';

    return '$sign${difference.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock History'),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : movements.isEmpty
          ? _buildEmptyState()
          : _buildMovementList(),
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
              Icons.history_outlined,
              size: 64,
              color: AppTheme.action,
            ),
            const SizedBox(height: 20),
            const Text(
              'No stock movements',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.header,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No stock movements have been recorded '
                  'for ${widget.item.name} yet.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: movements.length,
      itemBuilder: (context, index) {
        final movement = movements[index];

        final color = _movementColor(movement.type);
        final difference = movement.stockAfter -
            movement.stockBefore;

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
                      backgroundColor: color,
                      child: Icon(
                        _movementIcon(movement.type),
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
                            movement.type,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(
                              movement.createdAt,
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _quantityText(movement),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: difference >= 0
                            ? AppTheme.header
                            : Colors.red,
                      ),
                    ),
                  ],
                ),

                const Divider(height: 24),

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Stock Before',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      movement.stockBefore
                          .toStringAsFixed(0),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
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
                      'Stock After',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      movement.stockAfter
                          .toStringAsFixed(0),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.header,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Reason',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        movement.reason,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
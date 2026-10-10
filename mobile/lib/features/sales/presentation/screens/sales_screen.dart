import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../businesses/domain/entities/business.dart';
import '../../domain/entities/sale.dart';
import '../../domain/usecases/get_sales.dart';
import 'create_sale_screen.dart';

class SalesScreen extends StatefulWidget {
  final Business business;

  const SalesScreen({
    super.key,
    required this.business,
  });

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  late Future<List<Sale>> _salesFuture;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  void _loadSales() {
    _salesFuture = getIt<GetSales>()(widget.business.id);
  }

  Future<void> _refreshSales() async {
    setState(_loadSales);
    await _salesFuture;
  }

  Future<void> _openCreateSale() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateSaleScreen(
          business: widget.business,
        ),
      ),
    );

    if (!mounted) return;

    if (created == true) {
      setState(_loadSales);
    }
  }

  String _formatAmount(double amount) {
    return 'TZS ${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Sales'),
        backgroundColor: AppTheme.header,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Sale>>(
        future: _salesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    const Text('Failed to load sales.'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => setState(_loadSales),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final sales = snapshot.data ?? [];

          if (sales.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshSales,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 130),
                  Icon(
                    Icons.point_of_sale_outlined,
                    size: 72,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'No sales yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Record your first sale using the button below.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final totalSales = sales.fold<double>(
            0,
                (sum, sale) => sum + sale.total,
          );

          return RefreshIndicator(
            onRefresh: _refreshSales,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: AppTheme.header,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total recorded sales',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatAmount(totalSales),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${sales.length} transaction(s)',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Recent sales',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...sales.reversed.map(
                      (sale) => Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.background,
                        child: Icon(
                          Icons.receipt_long,
                          color: AppTheme.header,
                        ),
                      ),
                      title: Text(
                        sale.customerName?.trim().isNotEmpty == true
                            ? sale.customerName!
                            : 'Walk-in customer',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${_formatDate(sale.createdAt)}'
                            ' • ${sale.items.length} item line(s)\n'
                            '${sale.paymentMethod}',
                      ),
                      isThreeLine: true,
                      trailing: Text(
                        _formatAmount(sale.total),
                        style: TextStyle(
                          color: AppTheme.header,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateSale,
        backgroundColor: AppTheme.action,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('New Sale'),
      ),
    );
  }
}
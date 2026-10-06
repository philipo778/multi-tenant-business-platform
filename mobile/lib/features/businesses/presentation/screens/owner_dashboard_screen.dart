import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Business Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.header,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Monitor all your businesses from one place.',
            style: TextStyle(
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  title: 'Businesses',
                  value: '4',
                  icon: Icons.business_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  title: 'Active',
                  value: '3',
                  icon: Icons.check_circle_outline,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  title: 'Expenses',
                  value: '0',
                  icon: Icons.receipt_long_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  title: 'Reports',
                  value: '4',
                  icon: Icons.bar_chart_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          const Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.header,
            ),
          ),

          const SizedBox(height: 12),

          _quickAccessCard(
            icon: Icons.business_outlined,
            title: 'My Businesses',
            subtitle: 'View and manage all businesses',
          ),

          _quickAccessCard(
            icon: Icons.bar_chart_outlined,
            title: 'Reports',
            subtitle: 'View consolidated business reports',
          ),

          _quickAccessCard(
            icon: Icons.people_outline,
            title: 'Users & Staff',
            subtitle: 'Manage users and access',
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AppTheme.action,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.header,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAccessCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: AppTheme.action,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.header,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.header,
        ),
      ),
    );
  }
}
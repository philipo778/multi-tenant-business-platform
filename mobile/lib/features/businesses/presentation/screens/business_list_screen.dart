import 'package:flutter/material.dart';

import '../../domain/entities/business.dart';
import '../widgets/business_card.dart';
import 'business_dashboard_screen.dart';
import '../../../../shared/widgets/app_drawer.dart';
import 'create_business_screen.dart';

class BusinessListScreen extends StatelessWidget {
  const BusinessListScreen({super.key});

  final List<Business> businesses = const [
    Business(
      id: '1',
      name: 'Phililancer Stationery',
      category: 'Retail',
      location: 'Dar es Salaam',
      isActive: true,
      enabledModules: [
        'sales',
        'inventory',
        'expenses',
        'debts',
        'reports',
      ],
    ),
    Business(
      id: '2',
      name: 'Phililancer Mobile Money',
      category: 'Mobile Money',
      location: 'Dar es Salaam',
      isActive: true,
      enabledModules: [
        'transactions',
        'float',
        'cash',
        'vouchers',
        'reports',
      ],
    ),
    Business(
      id: '3',
      name: 'Phililancer Lodge',
      category: 'Lodge',
      location: 'Dodoma',
      isActive: true,
      enabledModules: [
        'rooms',
        'bookings',
        'expenses',
        'reports',
      ],
    ),
    Business(
      id: '4',
      name: 'Phililancer Beverage Shop',
      category: 'Beverage',
      location: 'Dar es Salaam',
      isActive: false,
      enabledModules: [
        'sales',
        'inventory',
        'expenses',
        'reports',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('My Businesses'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateBusinessScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: businesses.length,
        itemBuilder: (context, index) {
          return BusinessCard(
            business: businesses[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BusinessDashboardScreen(
                    business: businesses[index],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
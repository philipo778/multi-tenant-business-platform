import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/business.dart';
import '../../domain/usecases/get_businesses.dart';
import '../widgets/business_card.dart';
import 'business_dashboard_screen.dart';
import '../../../../shared/widgets/app_drawer.dart';
import 'create_business_screen.dart';

class BusinessListScreen extends StatefulWidget {
  const BusinessListScreen({super.key});

  @override
  State<BusinessListScreen> createState() => _BusinessListScreenState();
}

class _BusinessListScreenState extends State<BusinessListScreen> {
  final GetBusinesses _getBusinesses = getIt<GetBusinesses>();

  List<Business> businesses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

  Future<void> _loadBusinesses() async {
    final result = await _getBusinesses();

    if (!mounted) return;

    setState(() {
      businesses = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('My Businesses'),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateBusinessScreen(),
                ),
              );

              await _loadBusinesses();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : businesses.isEmpty
          ? const Center(
        child: Text(
          'No businesses found.',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: businesses.length,
        itemBuilder: (context, index) {
          final business = businesses[index];

          return BusinessCard(
            business: business,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BusinessDashboardScreen(
                        business: business,
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
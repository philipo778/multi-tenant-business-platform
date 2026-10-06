import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.header,
            ),
            accountName: const Text(
              'Philipo John',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: const Text(
              'Owner',
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: AppTheme.header,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.business_outlined),
            title: const Text('My Businesses'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.bar_chart_outlined),
            title: const Text('Reports'),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Expenses'),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Users & Staff'),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {},
          ),

          const Spacer(),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {},
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
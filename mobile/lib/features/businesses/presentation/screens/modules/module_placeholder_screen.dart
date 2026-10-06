import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/business.dart';

class ModulePlaceholderScreen extends StatelessWidget {
  final Business business;
  final String title;
  final String subtitle;

  const ModulePlaceholderScreen({
    super.key,
    required this.business,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.construction_outlined,
                size: 64,
                color: AppTheme.action,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.header,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                business.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.header,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                business.category,
                style: const TextStyle(
                  color: AppTheme.action,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Module coming soon.',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class DashboardModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const DashboardModuleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor:
                AppTheme.action.withValues(alpha: 0.1),
                child: Icon(
                  icon,
                  color: AppTheme.action,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.header,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: AppTheme.header,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/business.dart';

class BusinessCard extends StatelessWidget {
  final Business business;
  final VoidCallback? onTap;

  const BusinessCard({
    super.key,
    required this.business,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.header.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.store,
                  color: AppTheme.header,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.header,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      business.category,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.action,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: AppTheme.header,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            business.location,
                            style: const TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${business.enabledModules.length} modules enabled',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.header,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Column(
                children: [
                  Icon(
                    business.isActive
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: business.isActive
                        ? AppTheme.action
                        : AppTheme.border,
                    size: 22,
                  ),

                  const SizedBox(height: 8),

                  const Icon(
                    Icons.chevron_right,
                    color: AppTheme.header,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
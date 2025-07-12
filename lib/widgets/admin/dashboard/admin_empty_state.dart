import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class AdminEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;

  const AdminEmptyState({
    super.key,
    required this.message,
    required this.icon,
    this.subtitle,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppConstants.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppConstants.titleMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppConstants.bodySmall.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AdminEmptyActivityState extends StatelessWidget {
  const AdminEmptyActivityState({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminEmptyState(
      message: 'No Recent Activity',
      icon: Icons.history,
      subtitle: 'Activity will appear here as you manage your events',
    );
  }
}
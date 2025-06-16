import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class UserTypeSelector extends StatelessWidget {
  final String selectedRole;
  final Function(String) onRoleChanged;

  const UserTypeSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppConstants.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.group,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Account Type',
                style: AppConstants.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Choose the account type that best describes you',
            style: AppConstants.bodyMediumSecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // User Type Options
          Row(
            children: [
              Expanded(
                child: _buildUserTypeCard(
                  role: 'attendee',
                  title: 'Attendee',
                  subtitle: 'Join Events',
                  icon: Icons.event_seat,
                  description: 'Discover and attend amazing events',
                  gradient: AppConstants.eventSecondaryGradient,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildUserTypeCard(
                  role: 'organizer',
                  title: 'Organizer',
                  subtitle: 'Create Events',
                  icon: Icons.event,
                  description: 'Organize and manage events',
                  gradient: AppConstants.eventPrimaryGradient,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Role Description
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selectedRole == 'attendee'
                  ? AppConstants.secondaryColor.withOpacity(0.1)
                  : AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selectedRole == 'attendee'
                    ? AppConstants.secondaryColor.withOpacity(0.3)
                    : AppConstants.primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selectedRole == 'attendee' ? Icons.info_outline : Icons.pending_actions,
                  color: selectedRole == 'attendee'
                      ? AppConstants.secondaryColor
                      : AppConstants.warningColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedRole == 'attendee'
                        ? 'Attendee accounts are activated immediately. Start discovering events right away!'
                        : 'Organizer accounts require admin approval. You\'ll be notified once approved to start creating events.',
                    style: AppConstants.bodySmall.copyWith(
                      color: selectedRole == 'attendee'
                          ? AppConstants.secondaryDarkColor
                          : AppConstants.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeCard({
    required String role,
    required String title,
    required String subtitle,
    required IconData icon,
    required String description,
    required List<Color> gradient,
  }) {
    final isSelected = selectedRole == role;
    
    return GestureDetector(
      onTap: () => onRoleChanged(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradient.first.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : gradient.first.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? Colors.white : gradient.first,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppConstants.titleLarge.copyWith(
                color: isSelected ? Colors.white : AppConstants.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppConstants.bodySmall.copyWith(
                color: isSelected
                    ? Colors.white.withOpacity(0.9)
                    : AppConstants.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppConstants.bodySmall.copyWith(
                color: isSelected
                    ? Colors.white.withOpacity(0.8)
                    : AppConstants.textSecondaryColor,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
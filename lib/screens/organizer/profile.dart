import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/app_bar.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';
import 'package:megavent/models/organizer.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentRoute = '/organizer-profile';

  // Sample organizer data - replace with actual data from your state management
  late Organizer currentOrganizer;

  @override
  void initState() {
    super.initState();
    // Initialize with sample data matching the Organizer model
    currentOrganizer = Organizer(
      id: '1',
      fullName: 'Alice Manager',
      email: 'alice.manager@megavent.com',
      phone: '+254712345001',
      organization: 'MegaVent Events',
      jobTitle: 'Senior Event Manager',
      bio:
          'Passionate event organizer with 5+ years of experience in creating memorable experiences. Specialized in corporate events, conferences, and tech meetups.',
      profileImage:
          'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
      website: 'https://alicemanager.com',
      address: '123 Event Street',
      city: 'Nairobi',
      country: 'Kenya',
      isApproved: true,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
      totalEvents: 47,
      totalAttendees: 12500,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: OrganizerAppBar(
        title: 'MegaVent',
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: OrganizerSidebar(currentRoute: currentRoute),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profile Settings', style: AppConstants.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Manage your account and preferences',
              style: AppConstants.bodyLarge.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 32),

            // Profile Header Card
            _buildProfileHeaderCard(),
            const SizedBox(height: 24),

            // Stats Overview
            _buildStatsOverview(),
            const SizedBox(height: 24),

            // Personal Information
            _buildPersonalInfoSection(),
            const SizedBox(height: 24),

            // Contact Information
            _buildContactInfoSection(),
            const SizedBox(height: 24),

            // Professional Information
            _buildProfessionalInfoSection(),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard() {
    return Container(
      width: double.infinity,
      decoration: AppConstants.cardDecoration.copyWith(
        gradient: const LinearGradient(
          colors: AppConstants.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    image:
                        currentOrganizer.profileImage != null
                            ? DecorationImage(
                              image: NetworkImage(
                                currentOrganizer.profileImage!,
                              ),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  child:
                      currentOrganizer.profileImage == null
                          ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          )
                          : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _changeProfileImage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              currentOrganizer.fullName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currentOrganizer.jobTitle ?? 'Event Organizer',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    currentOrganizer.isApproved
                        ? AppConstants.successColor
                        : AppConstants.warningColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                currentOrganizer.approvalStatus,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            'Total Events',
            currentOrganizer.totalEvents.toString(),
            Icons.event,
            AppConstants.primaryColor,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Total Attendees',
            _formatNumber(currentOrganizer.totalAttendees),
            Icons.people,
            AppConstants.secondaryColor,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Experience Level',
            currentOrganizer.experienceLevel,
            Icons.star,
            AppConstants.accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: AppConstants.cardDecoration,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppConstants.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppConstants.bodySmall.copyWith(
              color: AppConstants.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildInfoSection('Personal Information', Icons.person_outline, [
      _buildInfoRow(
        'Full Name',
        currentOrganizer.fullName,
        Icons.badge_outlined,
      ),
      _buildInfoRow(
        'Bio',
        currentOrganizer.bio ?? 'No bio added',
        Icons.description_outlined,
      ),
      _buildInfoRow(
        'Experience Level',
        currentOrganizer.experienceLevel,
        Icons.star_outline,
      ),
      _buildInfoRow(
        'Member Since',
        _formatDate(currentOrganizer.createdAt),
        Icons.calendar_today_outlined,
      ),
      _buildInfoRow(
        'Last Updated',
        _formatDate(currentOrganizer.updatedAt),
        Icons.update_outlined,
      ),
    ]);
  }

  Widget _buildContactInfoSection() {
    return _buildInfoSection(
      'Contact Information',
      Icons.contact_mail_outlined,
      [
        _buildInfoRow(
          'Email',
          currentOrganizer.email,
          Icons.email_outlined,
          onTap: () => _launchEmail(currentOrganizer.email),
        ),
        _buildInfoRow(
          'Phone',
          currentOrganizer.phone,
          Icons.phone_outlined,
          onTap: () => _launchPhone(currentOrganizer.phone),
        ),
        _buildInfoRow(
          'Address',
          currentOrganizer.fullAddress.isEmpty
              ? 'No address added'
              : currentOrganizer.fullAddress,
          Icons.location_on_outlined,
        ),
      ],
    );
  }

  Widget _buildProfessionalInfoSection() {
    return _buildInfoSection('Professional Information', Icons.work_outline, [
      _buildInfoRow(
        'Organization',
        currentOrganizer.organization ?? 'Not specified',
        Icons.business_outlined,
      ),
      _buildInfoRow(
        'Job Title',
        currentOrganizer.jobTitle ?? 'Not specified',
        Icons.badge_outlined,
      ),
      _buildInfoRow(
        'Website',
        currentOrganizer.website ?? 'Not added',
        Icons.web_outlined,
        onTap:
            currentOrganizer.website != null
                ? () => _launchUrl(currentOrganizer.website!)
                : null,
      ),
    ]);
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _editProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.edit_outlined),
                const SizedBox(width: 8),
                Text(
                  'Edit Profile',
                  style: AppConstants.titleMedium.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: AppConstants.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppConstants.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(title, style: AppConstants.titleLarge),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppConstants.textSecondaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppConstants.bodySmall.copyWith(
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: AppConstants.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppConstants.textSecondaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Utility methods
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Action methods - implement these based on your app's functionality
  void _changeProfileImage() {
    // Implement profile image change functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile image change functionality coming soon'),
      ),
    );
  }

  void _editProfile() {
    // Navigate to edit profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile functionality coming soon')),
    );
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

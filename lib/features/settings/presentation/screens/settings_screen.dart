import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stocked/core/theme/app_theme.dart';
import 'package:stocked/core/widgets/universal_navbar.dart';
import 'package:stocked/core/providers/navigation_provider.dart';
import 'package:stocked/features/auth/presentation/providers/auth_provider.dart';
import 'package:stocked/core/services/config_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProviderNotifier);
    final user = authState.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Settings',
            style: AppTheme.heading1.copyWith(
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your account and preferences',
            style: AppTheme.body2.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 24),

          // User Profile Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.glassmorphicDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Profile',
                  style: AppTheme.heading3.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Icon(
                        CupertinoIcons.person_fill,
                        color: AppTheme.primaryColor,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'User',
                            style: AppTheme.heading3,
                          ),
                          Text(
                            user?.email ?? 'user@example.com',
                            style: AppTheme.body2.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                          Text(
                            user?.role ?? 'User',
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Settings Options
          Container(
            decoration: AppTheme.glassmorphicDecoration,
            child: Column(
              children: [
                _buildSettingsItem(
                  icon: CupertinoIcons.person_circle,
                  title: 'Account Settings',
                  subtitle: 'Manage your account information',
                  onTap: () => _showAccountSettings(context),
                ),
                _buildSettingsItem(
                  icon: CupertinoIcons.bell,
                  title: 'Notifications',
                  subtitle: 'Configure notification preferences',
                  onTap: () => _showNotificationSettings(context),
                ),
                _buildSettingsItem(
                  icon: CupertinoIcons.shield,
                  title: 'Privacy & Security',
                  subtitle: 'Manage privacy and security settings',
                  onTap: () => _showPrivacySettings(context),
                ),
                _buildSettingsItem(
                  icon: CupertinoIcons.gear,
                  title: 'App Settings',
                  subtitle: 'Configure app preferences',
                  onTap: () => _showAppSettings(context),
                ),
                _buildSettingsItem(
                  icon: CupertinoIcons.question_circle,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  onTap: () => _showHelpSupport(context),
                ),
                _buildSettingsItem(
                  icon: CupertinoIcons.info_circle,
                  title: 'About',
                  subtitle: 'App version and information',
                  onTap: () => _showAbout(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Sign Out Button
          Container(
            width: double.infinity,
            child: CupertinoButton(
              color: AppTheme.errorColor,
              borderRadius: BorderRadius.circular(12),
              onPressed: () => _showSignOutDialog(context),
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.body1,
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        subtitle,
                        style: AppTheme.caption,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.right_chevron,
              color: AppTheme.textSecondaryColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountSettings(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Account Settings'),
        content: const Text('This feature is under development.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Notification Settings'),
        content: const Text('This feature is under development.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Privacy & Security'),
        content: const Text('This feature is under development.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showAppSettings(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('App Settings'),
        content: const Text('This feature is under development.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Help & Support'),
        content: const Text('This feature is under development.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('About'),
        content: const Text('This feature is under development.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Sign Out'),
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement actual sign out logic
            },
          ),
        ],
      ),
    );
  }
}

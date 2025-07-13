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

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.only(bottom: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: AppTheme.heading1.copyWith(
                      color: AppTheme.primaryColor,
                      fontSize: 40,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your account and preferences',
                    style: AppTheme.body2.copyWith(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // User Profile Section
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.person_circle_fill,
                        color: AppTheme.primaryColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'User Profile',
                        style: AppTheme.heading3.copyWith(
                          color: AppTheme.primaryColor,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          CupertinoIcons.person_fill,
                          color: AppTheme.primaryColor,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'User',
                              style: AppTheme.heading3.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              user?.email ?? 'user@example.com',
                              style: AppTheme.body2.copyWith(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppTheme.primaryColor,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                user?.role ?? 'User',
                                style: AppTheme.caption.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
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

            const SizedBox(height: 32),

            // Settings Options
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSettingsItem(
                    icon: CupertinoIcons.person_circle,
                    title: 'Account Settings',
                    subtitle: 'Manage your account information and profile',
                    onTap: () => _showAccountSettings(context),
                  ),
                  _buildSettingsItem(
                    icon: CupertinoIcons.bell,
                    title: 'Notifications',
                    subtitle: 'Configure notification preferences and alerts',
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
                    subtitle: 'Configure app preferences and display options',
                    onTap: () => _showAppSettings(context),
                  ),
                  _buildSettingsItem(
                    icon: CupertinoIcons.question_circle,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact support team',
                    onTap: () => _showHelpSupport(context),
                  ),
                  _buildSettingsItem(
                    icon: CupertinoIcons.info_circle,
                    title: 'About',
                    subtitle: 'App version and information',
                    onTap: () => _showAbout(context),
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Sign Out Button
            Container(
              width: double.infinity,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 18),
                color: AppTheme.errorColor,
                borderRadius: BorderRadius.circular(16),
                onPressed: () => _showSignOutDialog(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.square_arrow_right,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sign Out',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // App Version Info
            Center(
              child: Text(
                'Stocked v1.0.0',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(24),
        onPressed: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                CupertinoIcons.right_chevron,
                color: AppTheme.textSecondaryColor,
                size: 16,
              ),
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

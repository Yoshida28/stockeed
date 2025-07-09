import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stocked/core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Container(
            decoration: AppTheme.glassmorphicDecoration,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(CupertinoIcons.settings,
                        color: AppTheme.primaryColor, size: 32),
                    const SizedBox(width: 12),
                    Text('Settings', style: AppTheme.heading2),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Profile', style: AppTheme.heading3),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(CupertinoIcons.person,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nitish Kumar', style: AppTheme.body1),
                        Text('nitish@example.com', style: AppTheme.caption),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text('Preferences', style: AppTheme.heading3),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Enable Notifications', style: AppTheme.body2),
                    const Spacer(),
                    CupertinoSwitch(value: true, onChanged: (_) {}),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Dark Mode', style: AppTheme.body2),
                    const Spacer(),
                    CupertinoSwitch(value: false, onChanged: (_) {}),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

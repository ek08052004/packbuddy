import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/dropdown_setting_widget.dart';
import './widgets/editable_field_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_item_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/toggle_setting_widget.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  // Mock user data
  final Map<String, dynamic> _userData = {
    "name": "Sarah Johnson",
    "email": "sarah.johnson@email.com",
    "avatar":
        "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400&h=400&fit=crop&crop=face",
    "preferredUnits": "Celsius",
    "gender": "Female",
    "defaultTripDuration": "7 days",
    "frequentDestinations": ["New York", "London", "Tokyo"],
    "packingPreferences": {
      "includeElectronics": true,
      "includeMedications": true,
      "includeBusinessAttire": false,
      "autoPackEssentials": true,
    },
    "notifications": {
      "packingReminders": true,
      "weatherUpdates": true,
      "tripAlerts": true,
    }
  };

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to logout from your account?',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/trip-setup-screen',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Account',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This action cannot be undone. All your data will be permanently deleted.',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              Text(
                'Please type "DELETE" to confirm:',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 1.h),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Type DELETE here',
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Handle account deletion
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
              ),
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );
  }

  void _exportTripHistory() {
    // Mock export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Trip history exported successfully'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Clear Cache',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'This will clear all cached data including offline packing lists. Continue?',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Cache cleared successfully'),
                    backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _resetRecommendations() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Reset Recommendations',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'This will reset all your packing preferences and recommendations. Continue?',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _userData["packingPreferences"] = {
                    "includeElectronics": true,
                    "includeMedications": true,
                    "includeBusinessAttire": false,
                    "autoPackEssentials": true,
                  };
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Recommendations reset successfully'),
                    backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          ProfileHeaderWidget(
            userName: _userData["name"] as String,
            userEmail: _userData["email"] as String,
            avatarUrl: _userData["avatar"] as String?,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 2.h),

                  // Personal Information Section
                  SettingsSectionWidget(
                    title: 'Personal Information',
                    children: [
                      EditableFieldWidget(
                        title: 'Full Name',
                        value: _userData["name"] as String,
                        iconName: 'person',
                        validator: _validateName,
                        onChanged: (value) {
                          setState(() {
                            _userData["name"] = value;
                          });
                        },
                      ),
                      EditableFieldWidget(
                        title: 'Email Address',
                        value: _userData["email"] as String,
                        iconName: 'email',
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        onChanged: (value) {
                          setState(() {
                            _userData["email"] = value;
                          });
                        },
                      ),
                      DropdownSettingWidget(
                        title: 'Temperature Units',
                        subtitle: 'Preferred temperature display',
                        value: _userData["preferredUnits"] as String,
                        options: const ['Celsius', 'Fahrenheit'],
                        iconName: 'thermostat',
                        onChanged: (value) {
                          setState(() {
                            _userData["preferredUnits"] = value;
                          });
                        },
                        showDivider: false,
                      ),
                    ],
                  ),

                  // Travel Profile Section
                  SettingsSectionWidget(
                    title: 'Travel Profile',
                    children: [
                      DropdownSettingWidget(
                        title: 'Gender',
                        subtitle: 'For personalized packing recommendations',
                        value: _userData["gender"] as String,
                        options: const [
                          'Male',
                          'Female',
                          'Other',
                          'Prefer not to say'
                        ],
                        iconName: 'person_outline',
                        onChanged: (value) {
                          setState(() {
                            _userData["gender"] = value;
                          });
                        },
                      ),
                      DropdownSettingWidget(
                        title: 'Default Trip Duration',
                        subtitle: 'Your typical trip length',
                        value: _userData["defaultTripDuration"] as String,
                        options: const [
                          '1-3 days',
                          '4-7 days',
                          '1-2 weeks',
                          '2+ weeks'
                        ],
                        iconName: 'schedule',
                        onChanged: (value) {
                          setState(() {
                            _userData["defaultTripDuration"] = value;
                          });
                        },
                      ),
                      SettingsItemWidget(
                        title: 'Frequent Destinations',
                        subtitle:
                            '${(_userData["frequentDestinations"] as List).length} destinations saved',
                        iconName: 'location_on',
                        onTap: () {
                          // Navigate to manage destinations
                        },
                        showDivider: false,
                      ),
                    ],
                  ),

                  // Packing Preferences Section
                  SettingsSectionWidget(
                    title: 'Packing Preferences',
                    children: [
                      ToggleSettingWidget(
                        title: 'Include Electronics',
                        subtitle: 'Automatically add chargers and adapters',
                        value: (_userData["packingPreferences"]
                            as Map)["includeElectronics"] as bool,
                        iconName: 'devices',
                        onChanged: (value) {
                          setState(() {
                            (_userData["packingPreferences"]
                                as Map)["includeElectronics"] = value;
                          });
                        },
                      ),
                      ToggleSettingWidget(
                        title: 'Include Medications',
                        subtitle: 'Add personal medication reminders',
                        value: (_userData["packingPreferences"]
                            as Map)["includeMedications"] as bool,
                        iconName: 'medical_services',
                        onChanged: (value) {
                          setState(() {
                            (_userData["packingPreferences"]
                                as Map)["includeMedications"] = value;
                          });
                        },
                      ),
                      ToggleSettingWidget(
                        title: 'Business Attire',
                        subtitle: 'Include formal clothing suggestions',
                        value: (_userData["packingPreferences"]
                            as Map)["includeBusinessAttire"] as bool,
                        iconName: 'business_center',
                        onChanged: (value) {
                          setState(() {
                            (_userData["packingPreferences"]
                                as Map)["includeBusinessAttire"] = value;
                          });
                        },
                      ),
                      ToggleSettingWidget(
                        title: 'Auto-Pack Essentials',
                        subtitle: 'Automatically include basic items',
                        value: (_userData["packingPreferences"]
                            as Map)["autoPackEssentials"] as bool,
                        iconName: 'auto_awesome',
                        onChanged: (value) {
                          setState(() {
                            (_userData["packingPreferences"]
                                as Map)["autoPackEssentials"] = value;
                          });
                        },
                        showDivider: false,
                      ),
                    ],
                  ),

                  // Data Management Section
                  SettingsSectionWidget(
                    title: 'Data Management',
                    children: [
                      SettingsItemWidget(
                        title: 'Export Trip History',
                        subtitle: 'Download your travel data',
                        iconName: 'download',
                        onTap: _exportTripHistory,
                      ),
                      SettingsItemWidget(
                        title: 'Clear Cache',
                        subtitle: 'Free up storage space',
                        iconName: 'delete_sweep',
                        onTap: _clearCache,
                      ),
                      SettingsItemWidget(
                        title: 'Reset Recommendations',
                        subtitle: 'Start fresh with packing suggestions',
                        iconName: 'refresh',
                        onTap: _resetRecommendations,
                        showDivider: false,
                      ),
                    ],
                  ),

                  // Notifications Section
                  SettingsSectionWidget(
                    title: 'Notifications',
                    children: [
                      SettingsItemWidget(
                        title: 'Notification Settings',
                        subtitle: 'Manage alerts and reminders',
                        iconName: 'notifications',
                        onTap: () {
                          Navigator.pushNamed(
                              context, '/notifications-settings-screen');
                        },
                        showDivider: false,
                      ),
                    ],
                  ),

                  // About Section
                  SettingsSectionWidget(
                    title: 'About',
                    children: [
                      SettingsItemWidget(
                        title: 'App Version',
                        subtitle: '2.1.0 (Build 2025.01)',
                        iconName: 'info',
                        onTap: () {},
                      ),
                      SettingsItemWidget(
                        title: 'Privacy Policy',
                        iconName: 'privacy_tip',
                        onTap: () {},
                      ),
                      SettingsItemWidget(
                        title: 'Terms of Service',
                        iconName: 'description',
                        onTap: () {},
                      ),
                      SettingsItemWidget(
                        title: 'Contact Support',
                        subtitle: 'Get help with PackBuddy',
                        iconName: 'support_agent',
                        onTap: () {},
                        showDivider: false,
                      ),
                    ],
                  ),

                  // Account Actions Section
                  SettingsSectionWidget(
                    title: 'Account',
                    children: [
                      SettingsItemWidget(
                        title: 'Logout',
                        iconName: 'logout',
                        titleColor: AppTheme.lightTheme.colorScheme.error,
                        onTap: _showLogoutDialog,
                      ),
                      SettingsItemWidget(
                        title: 'Delete Account',
                        subtitle: 'Permanently delete your account',
                        iconName: 'delete_forever',
                        titleColor: AppTheme.lightTheme.colorScheme.error,
                        onTap: _showDeleteAccountDialog,
                        showDivider: false,
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

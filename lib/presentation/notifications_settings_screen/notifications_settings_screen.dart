import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/notification_toggle_section.dart';
import './widgets/permission_status_card.dart';
import './widgets/preview_notification_button.dart';
import './widgets/quiet_hours_section.dart';
import './widgets/reminder_timing_section.dart';
import './widgets/sound_vibration_section.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  // Permission status
  bool _isNotificationEnabled = true;

  // Reminder timing
  String _selectedTiming = '3_days';

  // Critical items settings
  bool _criticalItemsEnabled = true;
  bool _passportReminder = true;
  bool _medicationReminder = true;
  bool _chargerReminder = false;

  // Weather alerts
  bool _weatherAlertsEnabled = true;
  bool _forecastChanges = true;
  bool _severeWeatherWarnings = true;

  // Trip updates
  bool _tripUpdatesEnabled = false;
  bool _packingListChanges = false;
  bool _recommendationChanges = true;

  // Sound and vibration
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _selectedSound = 'Default Notification';

  // Quiet hours
  bool _quietHoursEnabled = false;
  TimeOfDay _startTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 7, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 1.h),

              // Permission status card
              PermissionStatusCard(
                isNotificationEnabled: _isNotificationEnabled,
                onEnablePressed: _handleEnableNotifications,
              ),

              // Reminder timing section
              ReminderTimingSection(
                selectedTiming: _selectedTiming,
                onTimingChanged: _handleTimingChanged,
                onCustomTimePressed: _handleCustomTimePressed,
              ),

              // Critical items section
              NotificationToggleSection(
                title: 'Critical Items',
                iconName: 'priority_high',
                toggleOptions: [
                  {
                    'label': 'Critical Item Reminders',
                    'description':
                        'Separate urgent reminders for essential items',
                    'value': _criticalItemsEnabled,
                    'onChanged': (bool value) =>
                        setState(() => _criticalItemsEnabled = value),
                    'priority': 'high',
                  },
                  if (_criticalItemsEnabled) ...[
                    {
                      'label': 'Passport & Documents',
                      'description': 'Remind me about travel documents',
                      'value': _passportReminder,
                      'onChanged': (bool value) =>
                          setState(() => _passportReminder = value),
                      'priority': 'high',
                    },
                    {
                      'label': 'Medications',
                      'description': 'Remind me about prescription medicines',
                      'value': _medicationReminder,
                      'onChanged': (bool value) =>
                          setState(() => _medicationReminder = value),
                      'priority': 'high',
                    },
                    {
                      'label': 'Phone Charger',
                      'description': 'Remind me about electronic chargers',
                      'value': _chargerReminder,
                      'onChanged': (bool value) =>
                          setState(() => _chargerReminder = value),
                      'priority': 'normal',
                    },
                  ],
                ],
              ),

              // Weather alerts section
              NotificationToggleSection(
                title: 'Weather Alerts',
                iconName: 'wb_sunny',
                toggleOptions: [
                  {
                    'label': 'Weather Alerts',
                    'description': 'Get notified about weather changes',
                    'value': _weatherAlertsEnabled,
                    'onChanged': (bool value) =>
                        setState(() => _weatherAlertsEnabled = value),
                    'priority': 'normal',
                  },
                  if (_weatherAlertsEnabled) ...[
                    {
                      'label': 'Forecast Changes',
                      'description':
                          'Alert when destination weather forecast changes',
                      'value': _forecastChanges,
                      'onChanged': (bool value) =>
                          setState(() => _forecastChanges = value),
                      'priority': 'normal',
                    },
                    {
                      'label': 'Severe Weather Warnings',
                      'description':
                          'Important alerts for extreme weather conditions',
                      'value': _severeWeatherWarnings,
                      'onChanged': (bool value) =>
                          setState(() => _severeWeatherWarnings = value),
                      'priority': 'high',
                    },
                  ],
                ],
              ),

              // Trip updates section
              NotificationToggleSection(
                title: 'Trip Updates',
                iconName: 'update',
                toggleOptions: [
                  {
                    'label': 'Trip Updates',
                    'description':
                        'Notifications about trip and packing changes',
                    'value': _tripUpdatesEnabled,
                    'onChanged': (bool value) =>
                        setState(() => _tripUpdatesEnabled = value),
                    'priority': 'normal',
                  },
                  if (_tripUpdatesEnabled) ...[
                    {
                      'label': 'Packing List Changes',
                      'description':
                          'When items are added or removed from your list',
                      'value': _packingListChanges,
                      'onChanged': (bool value) =>
                          setState(() => _packingListChanges = value),
                      'priority': 'normal',
                    },
                    {
                      'label': 'New Recommendations',
                      'description':
                          'When new packing suggestions are available',
                      'value': _recommendationChanges,
                      'onChanged': (bool value) =>
                          setState(() => _recommendationChanges = value),
                      'priority': 'normal',
                    },
                  ],
                ],
              ),

              // Sound and vibration section
              SoundVibrationSection(
                soundEnabled: _soundEnabled,
                vibrationEnabled: _vibrationEnabled,
                selectedSound: _selectedSound,
                onSoundChanged: (bool value) =>
                    setState(() => _soundEnabled = value),
                onVibrationChanged: (bool value) =>
                    setState(() => _vibrationEnabled = value),
                onSoundSelectionPressed: _handleSoundSelection,
              ),

              // Quiet hours section
              QuietHoursSection(
                quietHoursEnabled: _quietHoursEnabled,
                startTime: _startTime,
                endTime: _endTime,
                onQuietHoursChanged: (bool value) =>
                    setState(() => _quietHoursEnabled = value),
                onStartTimePressed: () => _selectTime(context, true),
                onEndTimePressed: () => _selectTime(context, false),
              ),

              // Preview notification button
              PreviewNotificationButton(
                onPressed: _handlePreviewNotification,
              ),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.lightTheme.colorScheme.onSurface,
          size: 24,
        ),
      ),
      title: Text(
        'Notifications',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _handleSaveSettings,
          child: Text(
            'Save',
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  void _handleEnableNotifications() {
    // In a real app, this would open system settings
    setState(() {
      _isNotificationEnabled = true;
    });

    HapticFeedback.lightImpact();
    Fluttertoast.showToast(
      msg: "Notifications enabled successfully!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      textColor: Colors.white,
    );
  }

  void _handleTimingChanged(String timing) {
    setState(() {
      _selectedTiming = timing;
    });

    HapticFeedback.selectionClick();
    _saveSettingsAutomatically();
  }

  void _handleCustomTimePressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Custom Reminder Time',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Set your custom reminder schedule:',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              // In a real app, this would have time/date pickers
              Text(
                'Custom time picker would appear here',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedTiming = 'custom';
                });
                Navigator.pop(context);
                _saveSettingsAutomatically();
              },
              child: Text('Set Custom Time'),
            ),
          ],
        );
      },
    );
  }

  void _handleSoundSelection() {
    final List<String> soundOptions = [
      'Default Notification',
      'Gentle Bell',
      'Travel Chime',
      'Soft Ping',
      'Classic Alert',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Notification Sound',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: soundOptions
                .map((sound) => RadioListTile<String>(
                      title: Text(sound),
                      value: sound,
                      groupValue: _selectedSound,
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            _selectedSound = value;
                          });
                          Navigator.pop(context);
                          _saveSettingsAutomatically();
                        }
                      },
                      activeColor: AppTheme.lightTheme.colorScheme.primary,
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              hourMinuteTextColor: AppTheme.lightTheme.colorScheme.onSurface,
              dayPeriodTextColor: AppTheme.lightTheme.colorScheme.onSurface,
              dialHandColor: AppTheme.lightTheme.colorScheme.primary,
              dialBackgroundColor:
                  AppTheme.lightTheme.colorScheme.primaryContainer,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
      _saveSettingsAutomatically();
    }
  }

  void _handlePreviewNotification() {
    HapticFeedback.lightImpact();

    // Show a preview of what the notification would look like
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'notifications',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 48,
              ),
              SizedBox(height: 2.h),
              Text(
                'PackBuddy Reminder',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Don\'t forget to pack your passport and travel documents for your upcoming trip to Paris!',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              Text(
                'This is how your notifications will appear',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  void _handleSaveSettings() {
    HapticFeedback.lightImpact();
    _saveSettingsAutomatically();

    Fluttertoast.showToast(
      msg: "Notification settings saved successfully!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      textColor: Colors.white,
    );
  }

  void _saveSettingsAutomatically() {
    // In a real app, this would save to SharedPreferences or a database
    // For now, we'll just provide haptic feedback
    HapticFeedback.selectionClick();
  }
}

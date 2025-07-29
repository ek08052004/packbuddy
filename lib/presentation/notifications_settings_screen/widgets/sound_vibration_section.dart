import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class SoundVibrationSection extends StatelessWidget {
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String selectedSound;
  final Function(bool) onSoundChanged;
  final Function(bool) onVibrationChanged;
  final VoidCallback onSoundSelectionPressed;

  const SoundVibrationSection({
    Key? key,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.selectedSound,
    required this.onSoundChanged,
    required this.onVibrationChanged,
    required this.onSoundSelectionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'volume_up',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Sound & Vibration',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          _buildSoundOption(context),
          _buildVibrationOption(context),
          if (soundEnabled) _buildSoundSelectionOption(context),
        ],
      ),
    );
  }

  Widget _buildSoundOption(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification Sound',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Play sound when notifications arrive',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 4.w),
          Switch(
            value: soundEnabled,
            onChanged: onSoundChanged,
            activeColor: AppTheme.lightTheme.colorScheme.primary,
            activeTrackColor:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildVibrationOption(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vibration',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Vibrate device when notifications arrive',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 4.w),
          Switch(
            value: vibrationEnabled,
            onChanged: onVibrationChanged,
            activeColor: AppTheme.lightTheme.colorScheme.primary,
            activeTrackColor:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundSelectionOption(BuildContext context) {
    return InkWell(
      onTap: onSoundSelectionPressed,
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'music_note',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Tone',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    selectedSound,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

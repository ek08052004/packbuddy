import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WeatherAlertsWidget extends StatefulWidget {
  final List<Map<String, dynamic>> alerts;

  const WeatherAlertsWidget({
    Key? key,
    required this.alerts,
  }) : super(key: key);

  @override
  State<WeatherAlertsWidget> createState() => _WeatherAlertsWidgetState();
}

class _WeatherAlertsWidgetState extends State<WeatherAlertsWidget> {
  final Set<int> _expandedAlerts = {};

  @override
  Widget build(BuildContext context) {
    if (widget.alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'warning',
                  color: AppTheme.warningLight,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Weather Alerts',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.warningLight,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.alerts.length,
            itemBuilder: (context, index) {
              final alert = widget.alerts[index];
              final isExpanded = _expandedAlerts.contains(index);

              return Container(
                margin: EdgeInsets.only(bottom: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.warningLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.warningLight.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          isExpanded
                              ? _expandedAlerts.remove(index)
                              : _expandedAlerts.add(index);
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: AppTheme.warningLight
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CustomIconWidget(
                                iconName: _getAlertIcon(
                                    alert['severity'] as String? ?? 'moderate'),
                                color: AppTheme.warningLight,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    alert['title'] as String? ??
                                        'Weather Alert',
                                    style: AppTheme
                                        .lightTheme.textTheme.titleSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.warningLight,
                                    ),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    alert['summary'] as String? ??
                                        'Weather conditions may affect travel',
                                    style:
                                        AppTheme.lightTheme.textTheme.bodySmall,
                                    maxLines: isExpanded ? null : 2,
                                    overflow: isExpanded
                                        ? null
                                        : TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            CustomIconWidget(
                              iconName:
                                  isExpanded ? 'expand_less' : 'expand_more',
                              color: AppTheme.warningLight,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(
                              color:
                                  AppTheme.warningLight.withValues(alpha: 0.3),
                              height: 2.h,
                            ),
                            Text(
                              'Details:',
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              alert['description'] as String? ??
                                  'No additional details available.',
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                            ),
                            SizedBox(height: 2.h),
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'schedule',
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                  size: 16,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  'Valid: ${alert['startTime']} - ${alert['endTime']}',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getAlertIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'severe':
        return 'dangerous';
      case 'moderate':
        return 'warning';
      case 'minor':
        return 'info';
      default:
        return 'warning';
    }
  }
}

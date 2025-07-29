import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../utils/weather_service.dart';

class WeatherWarningWidget extends StatefulWidget {
  final String tripId;
  final VoidCallback? onWarningTap;

  const WeatherWarningWidget({
    Key? key,
    required this.tripId,
    this.onWarningTap,
  }) : super(key: key);

  @override
  State<WeatherWarningWidget> createState() => _WeatherWarningWidgetState();
}

class _WeatherWarningWidgetState extends State<WeatherWarningWidget> {
  final WeatherService _weatherService = WeatherService();
  List<Map<String, dynamic>> _severeAlerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeatherAlerts();
  }

  Future<void> _loadWeatherAlerts() async {
    try {
      final alerts =
          await _weatherService.getSevereWeatherAlerts(widget.tripId);
      if (mounted) {
        setState(() {
          _severeAlerts = alerts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _severeAlerts = [];
          _isLoading = false;
        });
      }
      debugPrint('Weather alerts error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.orange.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              'Loading weather alerts...',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.orange.shade700,
              ),
            ),
          ],
        ),
      );
    }

    if (_severeAlerts.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show the most severe alert
    final primaryAlert = _severeAlerts.first;
    final alertColor = _getAlertColor(primaryAlert['severity'] as String);
    final hasMultipleAlerts = _severeAlerts.length > 1;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: InkWell(
        onTap: widget.onWarningTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: alertColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: alertColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: alertColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: _getAlertIcon(primaryAlert['type'] as String),
                      color: alertColor,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                primaryAlert['title'] as String,
                                style: AppTheme.lightTheme.textTheme.titleSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: alertColor,
                                ),
                              ),
                            ),
                            if (hasMultipleAlerts)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 0.5.h),
                                decoration: BoxDecoration(
                                  color: alertColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '+${_severeAlerts.length - 1} more',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: alertColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          primaryAlert['description'] as String,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: alertColor,
                    size: 20,
                  ),
                ],
              ),
              if (_hasThunderstormAlert()) ...[
                SizedBox(height: 2.h),
                _buildPackingRecommendations(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackingRecommendations() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'lightbulb',
                color: Colors.blue,
                size: 16,
              ),
              SizedBox(width: 2.w),
              Text(
                'Packing Recommendations',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          ...[
            'Waterproof jacket',
            'Umbrella',
            'Waterproof bag/cover',
            'Extra dry clothes'
          ]
              .map((item) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.3.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 14,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          item,
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  bool _hasThunderstormAlert() {
    return _severeAlerts.any((alert) =>
        (alert['type'] as String).toLowerCase().contains('thunderstorm') ||
        (alert['type'] as String).toLowerCase().contains('storm'));
  }

  Color _getAlertColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'extreme':
        return const Color(0xFFD32F2F); // Red
      case 'severe':
        return const Color(0xFFF57C00); // Orange
      case 'moderate':
        return const Color(0xFFFBC02D); // Yellow
      case 'minor':
        return const Color(0xFF388E3C); // Green
      default:
        return const Color(0xFF757575); // Grey
    }
  }

  String _getAlertIcon(String alertType) {
    switch (alertType.toLowerCase()) {
      case 'thunderstorm':
      case 'storm':
        return 'thunderstorm';
      case 'rain':
      case 'heavy_rain':
        return 'rainy';
      case 'snow':
      case 'blizzard':
        return 'snowy';
      case 'wind':
      case 'high_wind':
        return 'air';
      case 'fog':
        return 'foggy';
      case 'heat':
      case 'extreme_heat':
        return 'wb_sunny';
      case 'cold':
      case 'extreme_cold':
        return 'ac_unit';
      default:
        return 'warning';
    }
  }
}

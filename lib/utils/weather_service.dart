import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import './supabase_service.dart';

class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  final Dio _dio = Dio();
  final SupabaseService _supabaseService = SupabaseService();

  // Get weather alerts for a trip
  Future<List<Map<String, dynamic>>> getWeatherAlerts(String tripId) async {
    try {
      final client = await _supabaseService.client;

      final response = await client
          .from('weather_alerts')
          .select()
          .eq('trip_id', tripId)
          .eq('is_active', true)
          .gte('end_time', DateTime.now().toIso8601String())
          .order('severity', ascending: false)
          .order('start_time', ascending: true);

      return response
          .map<Map<String, dynamic>>((alert) => {
                'id': alert['id'],
                'type': alert['alert_type'],
                'severity': alert['severity'],
                'title': alert['title'],
                'summary': alert['description'],
                'description': alert['description'],
                'startTime': _formatAlertTime(alert['start_time']),
                'endTime': _formatAlertTime(alert['end_time']),
                'isActive': alert['is_active'],
              })
          .toList();
    } catch (e) {
      debugPrint('Weather alerts error: $e');
      return [];
    }
  }

  // Create weather alert for a trip
  Future<void> createWeatherAlert({
    required String tripId,
    required String alertType,
    required String severity,
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final client = await _supabaseService.client;

      await client.from('weather_alerts').insert({
        'trip_id': tripId,
        'alert_type': alertType,
        'severity': severity,
        'title': title,
        'description': description,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'is_active': true,
      });
    } catch (e) {
      debugPrint('Create weather alert error: $e');
      rethrow;
    }
  }

  // Update weather alert status
  Future<void> updateWeatherAlertStatus(String alertId, bool isActive) async {
    try {
      final client = await _supabaseService.client;

      await client
          .from('weather_alerts')
          .update({'is_active': isActive}).eq('id', alertId);
    } catch (e) {
      debugPrint('Update weather alert error: $e');
      rethrow;
    }
  }

  // Get severe weather alerts for packing list
  Future<List<Map<String, dynamic>>> getSevereWeatherAlerts(
      String tripId) async {
    try {
      final client = await _supabaseService.client;

      final response = await client
          .from('weather_alerts')
          .select()
          .eq('trip_id', tripId)
          .eq('is_active', true)
          .inFilter('severity', ['severe', 'extreme'])
          .gte('end_time', DateTime.now().toIso8601String())
          .order('severity', ascending: false);

      return response
          .map<Map<String, dynamic>>((alert) => {
                'id': alert['id'],
                'type': alert['alert_type'],
                'severity': alert['severity'],
                'title': alert['title'],
                'description': alert['description'],
                'icon': _getWeatherAlertIcon(alert['alert_type']),
                'color': _getWeatherAlertColor(alert['severity']),
                'startTime': alert['start_time'],
                'endTime': alert['end_time'],
              })
          .toList();
    } catch (e) {
      debugPrint('Severe weather alerts error: $e');
      return [];
    }
  }

  // Generate sample weather alerts based on destination and dates
  Future<void> generateSampleWeatherAlerts({
    required String tripId,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Sample weather patterns based on common destinations
      final alerts =
          _getSampleAlertsForDestination(destination, startDate, endDate);

      for (final alert in alerts) {
        await createWeatherAlert(
          tripId: tripId,
          alertType: alert['type'],
          severity: alert['severity'],
          title: alert['title'],
          description: alert['description'],
          startTime: alert['startTime'],
          endTime: alert['endTime'],
        );
      }
    } catch (e) {
      debugPrint('Generate sample weather alerts error: $e');
    }
  }

  // Check for thunderstorm and severe weather conditions
  Future<bool> hasThunderstormAlert(String tripId) async {
    try {
      final alerts = await getSevereWeatherAlerts(tripId);
      return alerts.any((alert) =>
          (alert['type'] as String).toLowerCase().contains('thunderstorm') ||
          (alert['type'] as String).toLowerCase().contains('storm'));
    } catch (e) {
      return false;
    }
  }

  // Format alert time for display
  String _formatAlertTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = dateTime.difference(now);

      if (difference.inDays > 0) {
        return '${difference.inDays}d';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else {
        return 'Now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  // Get weather alert icon
  String _getWeatherAlertIcon(String alertType) {
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

  // Get weather alert color based on severity
  String _getWeatherAlertColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'extreme':
        return '#D32F2F'; // Red
      case 'severe':
        return '#F57C00'; // Orange
      case 'moderate':
        return '#FBC02D'; // Yellow
      case 'minor':
        return '#388E3C'; // Green
      default:
        return '#757575'; // Grey
    }
  }

  // Generate sample alerts for different destinations
  List<Map<String, dynamic>> _getSampleAlertsForDestination(
      String destination, DateTime startDate, DateTime endDate) {
    final alerts = <Map<String, dynamic>>[];
    final destinationLower = destination.toLowerCase();

    // Add thunderstorm alert for tropical/summer destinations
    if (destinationLower.contains('florida') ||
        destinationLower.contains('thailand') ||
        destinationLower.contains('singapore') ||
        destinationLower.contains('mumbai') ||
        destinationLower.contains('miami')) {
      alerts.add({
        'type': 'thunderstorm',
        'severity': 'moderate',
        'title': 'Thunderstorm Warning',
        'description':
            'Thunderstorms are expected in the $destination area. Pack waterproof clothing and consider indoor activities during storm periods.',
        'startTime': startDate.add(const Duration(days: 2)),
        'endTime': startDate.add(const Duration(days: 3)),
      });
    }

    // Add wind alerts for coastal areas
    if (destinationLower.contains('san francisco') ||
        destinationLower.contains('chicago') ||
        destinationLower.contains('wellington') ||
        destinationLower.contains('scotland')) {
      alerts.add({
        'type': 'high_wind',
        'severity': 'minor',
        'title': 'High Wind Advisory',
        'description':
            'Strong winds expected. Secure loose items and dress in layers.',
        'startTime': startDate.add(const Duration(days: 1)),
        'endTime': startDate.add(const Duration(days: 2)),
      });
    }

    // Add rain alerts for known rainy destinations
    if (destinationLower.contains('london') ||
        destinationLower.contains('seattle') ||
        destinationLower.contains('vancouver') ||
        destinationLower.contains('mumbai')) {
      alerts.add({
        'type': 'heavy_rain',
        'severity': 'moderate',
        'title': 'Heavy Rain Expected',
        'description':
            'Significant rainfall expected. Pack waterproof gear and plan indoor activities.',
        'startTime': startDate.add(const Duration(days: 3)),
        'endTime': startDate.add(const Duration(days: 4)),
      });
    }

    // Add extreme heat alerts for desert/hot regions
    if (destinationLower.contains('dubai') ||
        destinationLower.contains('phoenix') ||
        destinationLower.contains('las vegas') ||
        destinationLower.contains('delhi')) {
      alerts.add({
        'type': 'extreme_heat',
        'severity': 'severe',
        'title': 'Extreme Heat Warning',
        'description':
            'Dangerously high temperatures expected. Stay hydrated, seek shade, and limit outdoor activities during peak hours.',
        'startTime': startDate,
        'endTime': endDate,
      });
    }

    return alerts;
  }
}

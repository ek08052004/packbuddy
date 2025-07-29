import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

import './supabase_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final Location _location = Location();
  final SupabaseService _supabaseService = SupabaseService();

  // Search for locations globally using geocoding
  Future<List<Map<String, dynamic>>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      // Get cached results first
      final cachedResults = await _getCachedSearchResults(query);
      if (cachedResults.isNotEmpty) {
        return cachedResults;
      }

      // Perform geocoding search
      final locations = await geocoding.locationFromAddress(query);

      final results = <Map<String, dynamic>>[];

      for (final location in locations.take(10)) {
        try {
          final placemarks = await geocoding.placemarkFromCoordinates(
              location.latitude, location.longitude);

          if (placemarks.isNotEmpty) {
            final placemark = placemarks.first;
            final locationName = _formatLocationName(placemark);

            results.add({
              'name': locationName,
              'country': placemark.country ?? '',
              'coordinates': {
                'latitude': location.latitude,
                'longitude': location.longitude,
              },
              'type': 'search_result',
              'icon': _getLocationIcon(placemark),
              'formatted_address': _getFormattedAddress(placemark),
            });
          }
        } catch (e) {
          // Skip this location if reverse geocoding fails
          continue;
        }
      }

      // Cache the search results
      if (results.isNotEmpty) {
        await _cacheSearchResults(query, results);
      }

      return results;
    } catch (e) {
      debugPrint('Location search error: $e');
      return [];
    }
  }

  // Get user's current location
  Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      // Check permissions
      final hasPermission = await _requestLocationPermission();
      if (!hasPermission) return null;

      // Check if location service is enabled
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return null;
      }

      // Get current location
      final locationData = await _location.getLocation();

      if (locationData.latitude == null || locationData.longitude == null) {
        return null;
      }

      // Reverse geocode to get place information
      try {
        final placemarks = await geocoding.placemarkFromCoordinates(
          locationData.latitude!,
          locationData.longitude!,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          return {
            'name': 'Current Location',
            'formatted_name': _formatLocationName(placemark),
            'country': placemark.country ?? '',
            'coordinates': {
              'latitude': locationData.latitude!,
              'longitude': locationData.longitude!,
            },
            'type': 'current_location',
            'icon': 'my_location',
            'formatted_address': _getFormattedAddress(placemark),
          };
        }
      } catch (e) {
        // Return basic location info if reverse geocoding fails
        return {
          'name': 'Current Location',
          'formatted_name': 'Current Location',
          'country': '',
          'coordinates': {
            'latitude': locationData.latitude!,
            'longitude': locationData.longitude!,
          },
          'type': 'current_location',
          'icon': 'my_location',
          'formatted_address': 'Current Location',
        };
      }
    } catch (e) {
      debugPrint('Current location error: $e');
      return null;
    }

    return null;
  }

  // Get popular destinations
  Future<List<Map<String, dynamic>>> getPopularDestinations() async {
    return [
      {
        'name': 'New York, NY',
        'country': 'United States',
        'type': 'popular',
        'icon': 'location_city',
        'coordinates': {'latitude': 40.7128, 'longitude': -74.0060},
        'formatted_address': 'New York, NY, United States',
      },
      {
        'name': 'London, UK',
        'country': 'United Kingdom',
        'type': 'popular',
        'icon': 'location_city',
        'coordinates': {'latitude': 51.5074, 'longitude': -0.1278},
        'formatted_address': 'London, United Kingdom',
      },
      {
        'name': 'Tokyo, Japan',
        'country': 'Japan',
        'type': 'popular',
        'icon': 'location_city',
        'coordinates': {'latitude': 35.6762, 'longitude': 139.6503},
        'formatted_address': 'Tokyo, Japan',
      },
      {
        'name': 'Paris, France',
        'country': 'France',
        'type': 'popular',
        'icon': 'location_city',
        'coordinates': {'latitude': 48.8566, 'longitude': 2.3522},
        'formatted_address': 'Paris, France',
      },
      {
        'name': 'Dubai, UAE',
        'country': 'United Arab Emirates',
        'type': 'popular',
        'icon': 'location_city',
        'coordinates': {'latitude': 25.2048, 'longitude': 55.2708},
        'formatted_address': 'Dubai, United Arab Emirates',
      },
      {
        'name': 'Sydney, Australia',
        'country': 'Australia',
        'type': 'popular',
        'icon': 'location_city',
        'coordinates': {'latitude': -33.8688, 'longitude': 151.2093},
        'formatted_address': 'Sydney, Australia',
      },
    ];
  }

  // Get recent search history
  Future<List<Map<String, dynamic>>> getRecentSearches() async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) return [];

      final response = await client
          .from('location_searches')
          .select()
          .eq('user_id', user.id)
          .order('last_searched_at', ascending: false)
          .limit(5);

      return response
          .map<Map<String, dynamic>>((item) => {
                'name': item['selected_location'] as String,
                'country': item['country'] as String? ?? '',
                'type': 'recent',
                'icon': 'history',
                'coordinates': item['location_coordinates'] != null
                    ? _parseCoordinates(item['location_coordinates'] as String)
                    : null,
                'formatted_address': item['selected_location'] as String,
              })
          .toList();
    } catch (e) {
      debugPrint('Recent searches error: $e');
      return [];
    }
  }

  // Save search to history
  Future<void> saveLocationSearch({
    required String query,
    required String selectedLocation,
    required Map<String, double> coordinates,
    String? country,
  }) async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) return;

      // Check if search exists
      final existing = await client
          .from('location_searches')
          .select('id, search_count')
          .eq('user_id', user.id)
          .eq('search_query', query.toLowerCase())
          .eq('selected_location', selectedLocation)
          .maybeSingle();

      if (existing != null) {
        // Update existing search
        await client.from('location_searches').update({
          'search_count': (existing['search_count'] as int) + 1,
          'last_searched_at': DateTime.now().toIso8601String(),
        }).eq('id', existing['id']);
      } else {
        // Create new search record
        await client.from('location_searches').insert({
          'user_id': user.id,
          'search_query': query.toLowerCase(),
          'selected_location': selectedLocation,
          'location_coordinates':
              'POINT(${coordinates['longitude']} ${coordinates['latitude']})',
          'country': country,
          'search_count': 1,
          'last_searched_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Save location search error: $e');
    }
  }

  // Request location permission
  Future<bool> _requestLocationPermission() async {
    if (kIsWeb) return true; // Browser handles permissions

    final status = await Permission.location.request();
    return status.isGranted;
  }

  // Format location name
  String _formatLocationName(geocoding.Placemark placemark) {
    final components = <String>[];

    if (placemark.locality?.isNotEmpty == true) {
      components.add(placemark.locality!);
    } else if (placemark.subAdministrativeArea?.isNotEmpty == true) {
      components.add(placemark.subAdministrativeArea!);
    }

    if (placemark.administrativeArea?.isNotEmpty == true) {
      components.add(placemark.administrativeArea!);
    }

    if (placemark.country?.isNotEmpty == true) {
      components.add(placemark.country!);
    }

    return components.join(', ');
  }

  // Get formatted address
  String _getFormattedAddress(geocoding.Placemark placemark) {
    final components = <String>[];

    if (placemark.name?.isNotEmpty == true) {
      components.add(placemark.name!);
    }
    if (placemark.thoroughfare?.isNotEmpty == true) {
      components.add(placemark.thoroughfare!);
    }
    if (placemark.locality?.isNotEmpty == true) {
      components.add(placemark.locality!);
    }
    if (placemark.administrativeArea?.isNotEmpty == true) {
      components.add(placemark.administrativeArea!);
    }
    if (placemark.country?.isNotEmpty == true) {
      components.add(placemark.country!);
    }

    return components.join(', ');
  }

  // Get location icon based on place type
  String _getLocationIcon(geocoding.Placemark placemark) {
    final locality = placemark.locality?.toLowerCase() ?? '';
    final area = placemark.administrativeArea?.toLowerCase() ?? '';

    if (locality.contains('airport') || area.contains('airport')) {
      return 'flight';
    } else if (locality.isNotEmpty) {
      return 'location_city';
    } else {
      return 'place';
    }
  }

  // Parse coordinates from PostGIS POINT format
  Map<String, double> _parseCoordinates(String pointString) {
    try {
      // Format: POINT(longitude latitude)
      final coords =
          pointString.replaceAll('POINT(', '').replaceAll(')', '').split(' ');

      return {
        'latitude': double.parse(coords[1]),
        'longitude': double.parse(coords[0]),
      };
    } catch (e) {
      return {'latitude': 0.0, 'longitude': 0.0};
    }
  }

  // Get cached search results
  Future<List<Map<String, dynamic>>> _getCachedSearchResults(
      String query) async {
    try {
      final client = await _supabaseService.client;

      final response = await client
          .from('location_searches')
          .select()
          .ilike('search_query', '%$query%')
          .order('search_count', ascending: false)
          .limit(5);

      return response
          .map<Map<String, dynamic>>((item) => {
                'name': item['selected_location'] as String,
                'country': item['country'] as String? ?? '',
                'type': 'cached',
                'icon': 'search',
                'coordinates': item['location_coordinates'] != null
                    ? _parseCoordinates(item['location_coordinates'] as String)
                    : null,
                'formatted_address': item['selected_location'] as String,
              })
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Cache search results
  Future<void> _cacheSearchResults(
      String query, List<Map<String, dynamic>> results) async {
    // Results are cached when user selects a location via saveLocationSearch
    // This method is kept for potential future caching strategies
  }
}

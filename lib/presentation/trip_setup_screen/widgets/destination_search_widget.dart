import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../utils/location_service.dart';

class DestinationSearchWidget extends StatefulWidget {
  final Function(String) onDestinationSelected;
  final String? initialDestination;

  const DestinationSearchWidget({
    Key? key,
    required this.onDestinationSelected,
    this.initialDestination,
  }) : super(key: key);

  @override
  State<DestinationSearchWidget> createState() =>
      _DestinationSearchWidgetState();
}

class _DestinationSearchWidgetState extends State<DestinationSearchWidget> {
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LocationService _locationService = LocationService();

  bool _showSuggestions = false;
  bool _isSearching = false;
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _recentSearches = [];
  List<Map<String, dynamic>> _popularDestinations = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialDestination != null) {
      _destinationController.text = widget.initialDestination!;
    }

    _focusNode.addListener(() {
      setState(() {
        _showSuggestions = _focusNode.hasFocus;
      });
      if (_focusNode.hasFocus) {
        _loadInitialData();
      }
    });

    _loadInitialData();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final [recent, popular] = await Future.wait([
        _locationService.getRecentSearches(),
        _locationService.getPopularDestinations(),
      ]);

      setState(() {
        _recentSearches = recent;
        _popularDestinations = popular;
      });
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    }
  }

  Future<void> _searchLocations(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await _locationService.searchLocations(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      debugPrint('Location search error: $e');
    }
  }

  List<Map<String, dynamic>> _getFilteredSuggestions() {
    if (_searchQuery.isNotEmpty && _searchResults.isNotEmpty) {
      return _searchResults;
    }

    if (_searchQuery.isEmpty) {
      return [..._recentSearches, ..._popularDestinations];
    }

    // Fallback filtering for cached/popular destinations
    final allDestinations = [..._recentSearches, ..._popularDestinations];
    return allDestinations.where((destination) {
      final name = (destination["name"] as String).toLowerCase();
      final country = (destination["country"] as String).toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || country.contains(query);
    }).toList();
  }

  void _selectDestination(Map<String, dynamic> destination) {
    final destinationName = destination["name"] as String;
    _destinationController.text = destinationName;
    _focusNode.unfocus();
    setState(() {
      _showSuggestions = false;
    });

    // Save to search history if it has coordinates
    final coordinates = destination["coordinates"] as Map<String, dynamic>?;
    if (coordinates != null) {
      _locationService.saveLocationSearch(
        query: _searchQuery.isNotEmpty
            ? _searchQuery
            : destinationName.toLowerCase(),
        selectedLocation: destinationName,
        coordinates: {
          'latitude': coordinates['latitude'] as double,
          'longitude': coordinates['longitude'] as double,
        },
        country: destination["country"] as String?,
      );
    }

    widget.onDestinationSelected(destinationName);
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isSearching = true);

    try {
      final currentLocation = await _locationService.getCurrentLocation();
      if (currentLocation != null) {
        _selectDestination(currentLocation);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Unable to get current location. Please check permissions.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to get current location.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Where are you going?",
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _destinationController,
            focusNode: _focusNode,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _showSuggestions = true;
              });

              // Debounced search
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_searchQuery == value && value.isNotEmpty) {
                  _searchLocations(value);
                }
              });
            },
            decoration: InputDecoration(
              hintText: "Search destinations worldwide...",
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'location_on',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
              ),
              suffixIcon: _isSearching
                  ? Padding(
                      padding: EdgeInsets.all(3.w),
                      child: SizedBox(
                        width: 4.w,
                        height: 4.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: _useCurrentLocation,
                      child: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: CustomIconWidget(
                          iconName: 'my_location',
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          size: 6.w,
                        ),
                      ),
                    ),
              filled: true,
              fillColor: AppTheme.lightTheme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        _showSuggestions
            ? _buildSuggestionsDropdown()
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildSuggestionsDropdown() {
    final suggestions = _getFilteredSuggestions();

    if (suggestions.isEmpty && !_isSearching) {
      return Container(
        margin: EdgeInsets.only(top: 1.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          _searchQuery.isNotEmpty
              ? 'No destinations found for "$_searchQuery"'
              : 'Start typing to search destinations...',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(top: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      constraints: BoxConstraints(
        maxHeight: 30.h,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(vertical: 1.h),
        itemCount: suggestions.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          final isRecent = (suggestion["type"] as String) == "recent";
          final isPopular = (suggestion["type"] as String) == "popular";
          final isCached = (suggestion["type"] as String) == "cached";

          return ListTile(
            onTap: () => _selectDestination(suggestion),
            leading: CustomIconWidget(
              iconName: suggestion["icon"] as String,
              color: isRecent
                  ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  : AppTheme.lightTheme.colorScheme.primary,
              size: 5.w,
            ),
            title: Text(
              suggestion["name"] as String,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              suggestion["country"] as String,
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
            trailing: isRecent
                ? Text(
                    "Recent",
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  )
                : isPopular
                    ? Icon(
                        Icons.star,
                        size: 16,
                        color: AppTheme.lightTheme.colorScheme.secondary,
                      )
                    : isCached
                        ? Icon(
                            Icons.trending_up,
                            size: 16,
                            color: AppTheme.lightTheme.colorScheme.tertiary,
                          )
                        : null,
          );
        },
      ),
    );
  }
}

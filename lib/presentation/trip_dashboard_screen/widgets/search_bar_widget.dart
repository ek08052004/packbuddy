import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final VoidCallback? onFilterTap;
  final bool isExpanded;

  const SearchBarWidget({
    Key? key,
    required this.onSearchChanged,
    this.onFilterTap,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isExpanded) {
      _animationController.forward();
      _isSearchActive = true;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (_isSearchActive) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        _searchController.clear();
        widget.onSearchChanged('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            children: [
              // Search bar container
              Container(
                height: 6.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Search icon/button
                    GestureDetector(
                      onTap: _toggleSearch,
                      child: Container(
                        width: 12.w,
                        height: 6.h,
                        child: CustomIconWidget(
                          iconName: _isSearchActive ? 'close' : 'search',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                    ),
                    // Search input field
                    Expanded(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: _slideAnimation.value * 100.w,
                        child: _slideAnimation.value > 0.1
                            ? TextField(
                                controller: _searchController,
                                onChanged: widget.onSearchChanged,
                                decoration: InputDecoration(
                                  hintText:
                                      'Search trips by destination or date...',
                                  hintStyle: TextStyle(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 1.h,
                                  ),
                                ),
                                style: TextStyle(
                                  color:
                                      AppTheme.lightTheme.colorScheme.onSurface,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            : SizedBox.shrink(),
                      ),
                    ),
                    // Filter button
                    if (_isSearchActive)
                      GestureDetector(
                        onTap: widget.onFilterTap,
                        child: Container(
                          width: 12.w,
                          height: 6.h,
                          child: CustomIconWidget(
                            iconName: 'tune',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Filter chips (shown when search is active)
              if (_isSearchActive && _slideAnimation.value > 0.5)
                Container(
                  margin: EdgeInsets.only(top: 2.h),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All Trips', true),
                        SizedBox(width: 2.w),
                        _buildFilterChip('Upcoming', false),
                        SizedBox(width: 2.w),
                        _buildFilterChip('Past Trips', false),
                        SizedBox(width: 2.w),
                        _buildFilterChip('This Month', false),
                        SizedBox(width: 2.w),
                        _buildFilterChip('Business', false),
                        SizedBox(width: 2.w),
                        _buildFilterChip('Leisure', false),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        // Handle filter selection
        widget.onSearchChanged(label == 'All Trips' ? '' : label);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : AppTheme.lightTheme.colorScheme.onSurface,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

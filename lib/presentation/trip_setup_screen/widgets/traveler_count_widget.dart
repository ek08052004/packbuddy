import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TravelerCountWidget extends StatefulWidget {
  final Function(int) onTravelerCountChanged;
  final int? initialCount;

  const TravelerCountWidget({
    Key? key,
    required this.onTravelerCountChanged,
    this.initialCount,
  }) : super(key: key);

  @override
  State<TravelerCountWidget> createState() => _TravelerCountWidgetState();
}

class _TravelerCountWidgetState extends State<TravelerCountWidget> {
  int _travelerCount = 1;

  @override
  void initState() {
    super.initState();
    if (widget.initialCount != null && widget.initialCount! > 0) {
      _travelerCount = widget.initialCount!;
    }
  }

  void _incrementCount() {
    if (_travelerCount < 10) {
      setState(() {
        _travelerCount++;
      });
      widget.onTravelerCountChanged(_travelerCount);
    }
  }

  void _decrementCount() {
    if (_travelerCount > 1) {
      setState(() {
        _travelerCount--;
      });
      widget.onTravelerCountChanged(_travelerCount);
    }
  }

  String _getTravelerText() {
    return _travelerCount == 1 ? "traveler" : "travelers";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Number of Travelers",
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          "This affects quantity recommendations for shared items",
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'group',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$_travelerCount ${_getTravelerText()}",
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      "Including yourself",
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildCounterButton(
                    icon: 'remove',
                    onTap: _decrementCount,
                    enabled: _travelerCount > 1,
                  ),
                  SizedBox(width: 4.w),
                  Container(
                    width: 12.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _travelerCount.toString(),
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  _buildCounterButton(
                    icon: 'add',
                    onTap: _incrementCount,
                    enabled: _travelerCount < 10,
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        _buildTravelerInfo(),
      ],
    );
  }

  Widget _buildCounterButton({
    required String icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 10.w,
        height: 6.h,
        decoration: BoxDecoration(
          color: enabled
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            color: enabled
                ? Colors.white
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.5),
            size: 5.w,
          ),
        ),
      ),
    );
  }

  Widget _buildTravelerInfo() {
    final List<Map<String, dynamic>> sharedItems = [
      {
        "category": "Electronics",
        "items": ["Phone chargers", "Power adapters", "Portable batteries"],
        "icon": "electrical_services"
      },
      {
        "category": "Toiletries",
        "items": ["Toothpaste", "Shampoo", "Sunscreen"],
        "icon": "soap"
      },
      {
        "category": "Documents",
        "items": ["Travel insurance", "Emergency contacts", "Itinerary"],
        "icon": "description"
      }
    ];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.tertiaryContainer
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                "Shared Items Adjustment",
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            "We'll adjust quantities for items that can be shared among $_travelerCount ${_getTravelerText()}:",
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          ...sharedItems
              .map((category) => Padding(
                    padding: EdgeInsets.only(bottom: 1.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomIconWidget(
                          iconName: category["icon"] as String,
                          color: AppTheme.lightTheme.colorScheme.tertiary
                              .withValues(alpha: 0.7),
                          size: 4.w,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category["category"] as String,
                                style: AppTheme.lightTheme.textTheme.labelMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                (category["items"] as List<String>).join(", "),
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CategoryCardWidget extends StatefulWidget {
  final Map<String, dynamic> categoryData;
  final Function(String, bool) onItemToggle;
  final Function(String) onItemEdit;
  final Function(String) onItemRemove;
  final Function(String) onItemNote;
  final Function(String) onItemCritical;

  const CategoryCardWidget({
    Key? key,
    required this.categoryData,
    required this.onItemToggle,
    required this.onItemEdit,
    required this.onItemRemove,
    required this.onItemNote,
    required this.onItemCritical,
  }) : super(key: key);

  @override
  State<CategoryCardWidget> createState() => _CategoryCardWidgetState();
}

class _CategoryCardWidgetState extends State<CategoryCardWidget> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final items =
        (widget.categoryData["items"] as List).cast<Map<String, dynamic>>();
    final completedItems =
        items.where((item) => item["isChecked"] == true).length;
    final totalItems = items.length;
    final progress = totalItems > 0 ? completedItems / totalItems : 0.0;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => isExpanded = !isExpanded),
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: widget.categoryData["icon"] as String,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 24,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.categoryData["name"] as String,
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          "$completedItems of $totalItems items",
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: progress == 1.0
                          ? AppTheme.lightTheme.colorScheme.secondaryContainer
                          : AppTheme.lightTheme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${(progress * 100).round()}%",
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: progress == 1.0
                            ? AppTheme.lightTheme.colorScheme.secondary
                            : AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  CustomIconWidget(
                    iconName: isExpanded ? 'expand_less' : 'expand_more',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            height: 2,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0
                    ? AppTheme.lightTheme.colorScheme.secondary
                    : AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
          if (isExpanded) ...[
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Dismissible(
                  key: Key(item["id"].toString()),
                  background: Container(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 4.w),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'edit',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          "Edit",
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  secondaryBackground: Container(
                    color: AppTheme.lightTheme.colorScheme.errorContainer,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 4.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Remove",
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        CustomIconWidget(
                          iconName: 'delete',
                          color: AppTheme.lightTheme.colorScheme.error,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      widget.onItemEdit(item["id"].toString());
                      return false;
                    } else if (direction == DismissDirection.endToStart) {
                      if (item["isEssential"] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Essential items cannot be removed"),
                            backgroundColor:
                                AppTheme.lightTheme.colorScheme.error,
                          ),
                        );
                        return false;
                      }
                      widget.onItemRemove(item["id"].toString());
                      return true;
                    }
                    return false;
                  },
                  child: InkWell(
                    onLongPress: () => _showItemContextMenu(context, item),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: item["isChecked"] as bool,
                            onChanged: (value) {
                              widget.onItemToggle(
                                  item["id"].toString(), value ?? false);
                            },
                          ),
                          SizedBox(width: 2.w),
                          CustomIconWidget(
                            iconName: item["icon"] as String,
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 20,
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
                                        item["name"] as String,
                                        style: AppTheme
                                            .lightTheme.textTheme.bodyMedium
                                            ?.copyWith(
                                          decoration:
                                              (item["isChecked"] as bool)
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                          color: (item["isChecked"] as bool)
                                              ? AppTheme.lightTheme.colorScheme
                                                  .onSurfaceVariant
                                              : AppTheme.lightTheme.colorScheme
                                                  .onSurface,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (item["isCritical"] == true) ...[
                                      SizedBox(width: 2.w),
                                      CustomIconWidget(
                                        iconName: 'priority_high',
                                        color: AppTheme
                                            .lightTheme.colorScheme.error,
                                        size: 16,
                                      ),
                                    ],
                                  ],
                                ),
                                if (item["quantity"] != null &&
                                    (item["quantity"] as int) > 1) ...[
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    "Qty: ${item["quantity"]}",
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ],
                                if (item["note"] != null &&
                                    (item["note"] as String).isNotEmpty) ...[
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    item["note"] as String,
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.tertiary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  void _showItemContextMenu(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              item["name"] as String,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text("Share Item"),
              onTap: () {
                Navigator.pop(context);
                // Share functionality would be implemented here
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'lightbulb_outline',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text("Similar Items"),
              onTap: () {
                Navigator.pop(context);
                // Similar items functionality would be implemented here
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'help_outline',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text("Why Recommended"),
              onTap: () {
                Navigator.pop(context);
                _showWhyRecommendedDialog(context, item);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showWhyRecommendedDialog(
      BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Why Recommended"),
        content: Text(
          item["recommendation"] as String? ??
              "This item is recommended based on your destination weather and trip duration.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Got it"),
          ),
        ],
      ),
    );
  }
}

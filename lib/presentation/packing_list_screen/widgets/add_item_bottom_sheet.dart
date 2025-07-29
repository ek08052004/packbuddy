import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AddItemBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddItem;
  final List<String> categories;

  const AddItemBottomSheet({
    Key? key,
    required this.onAddItem,
    required this.categories,
  }) : super(key: key);

  @override
  State<AddItemBottomSheet> createState() => _AddItemBottomSheetState();
}

class _AddItemBottomSheetState extends State<AddItemBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _selectedCategory = '';
  int _quantity = 1;
  bool _isCritical = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory =
        widget.categories.isNotEmpty ? widget.categories.first : '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
            "Add New Item",
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Item Name",
              hintText: "Enter item name",
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'inventory_2',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: "Category",
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'category',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
            items: widget.categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value ?? '';
              });
            },
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quantity",
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                            icon: CustomIconWidget(
                              iconName: 'remove',
                              color: _quantity > 1
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _quantity.toString(),
                              textAlign: TextAlign.center,
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _quantity < 99
                                ? () => setState(() => _quantity++)
                                : null,
                            icon: CustomIconWidget(
                              iconName: 'add',
                              color: _quantity < 99
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Critical Item",
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SwitchListTile(
                        value: _isCritical,
                        onChanged: (value) =>
                            setState(() => _isCritical = value),
                        title: Text(
                          _isCritical ? "Yes" : "No",
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 2.w),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Note (Optional)",
              hintText: "Add any additional notes...",
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'note',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      _nameController.text.trim().isNotEmpty ? _addItem : null,
                  child: Text("Add Item"),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  void _addItem() {
    final newItem = {
      "id": DateTime.now().millisecondsSinceEpoch,
      "name": _nameController.text.trim(),
      "category": _selectedCategory,
      "quantity": _quantity,
      "isCritical": _isCritical,
      "note": _noteController.text.trim(),
      "isChecked": false,
      "isEssential": false,
      "icon": _getCategoryIcon(_selectedCategory),
      "recommendation": "Added manually by user",
    };

    widget.onAddItem(newItem);
    Navigator.pop(context);
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'clothing':
        return 'checkroom';
      case 'electronics':
        return 'devices';
      case 'documents':
        return 'description';
      case 'toiletries':
        return 'soap';
      case 'essentials':
        return 'star';
      default:
        return 'inventory_2';
    }
  }
}

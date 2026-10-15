import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// A customizable quick chip item configuration.
class QuickChipItem {
  final String label;
  final String? iconText;
  final IconData? icon;
  final String? value;

  const QuickChipItem({
    required this.label,
    this.iconText,
    this.icon,
    this.value,
  });
}

/// A horizontal or wrapping group of sleek interactive quick-action chips.
class QuickChipGroup extends StatelessWidget {
  final List<QuickChipItem> items;
  final Set<String> selectedLabels;
  final ValueChanged<QuickChipItem> onChipTapped;
  final bool isMultiSelect;
  final bool scrollable;
  final Color? activeColor;
  final Color? activeBackgroundColor;
  final Color? inactiveBackgroundColor;
  final EdgeInsetsGeometry padding;

  const QuickChipGroup({
    super.key,
    required this.items,
    this.selectedLabels = const {},
    required this.onChipTapped,
    this.isMultiSelect = true,
    this.scrollable = true,
    this.activeColor,
    this.activeBackgroundColor,
    this.inactiveBackgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: padding,
        child: Row(
          children: items.map((item) {
            final isSelected = selectedLabels.contains(item.label);
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildChip(context, item, isSelected),
            );
          }).toList(),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: items.map((item) {
          final isSelected = selectedLabels.contains(item.label);
          return _buildChip(context, item, isSelected);
        }).toList(),
      ),
    );
  }

  Widget _buildChip(BuildContext context, QuickChipItem item, bool isSelected) {
    final effectiveActiveColor = activeColor ?? AppColors.primary;
    final effectiveActiveBg = activeBackgroundColor ?? AppColors.primaryMint;
    final effectiveInactiveBg = inactiveBackgroundColor ?? AppColors.surface;

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChipTapped(item),
          borderRadius: BorderRadius.circular(24),
          splashColor: effectiveActiveColor.withValues(alpha: 0.15),
          highlightColor: effectiveActiveColor.withValues(alpha: 0.08),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            constraints: const BoxConstraints(minHeight: 38, minWidth: 44),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? effectiveActiveBg : effectiveInactiveBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? effectiveActiveColor
                    : AppColors.border,
                width: isSelected ? 1.4 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: effectiveActiveColor.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.icon != null) ...[
                  Icon(
                    item.icon,
                    size: 15,
                    color: isSelected ? effectiveActiveColor : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                ] else if (item.iconText != null) ...[
                  Text(
                    item.iconText!,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? effectiveActiveColor : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? effectiveActiveColor : AppColors.textPrimary,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.check,
                    size: 14,
                    color: effectiveActiveColor,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

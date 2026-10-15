import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Enum describing the visual status / category of a meal card.
enum MealCategory {
  breakfast,
  lunch,
  snack,
  dinner,
}

/// Data model representing a meal entry for today.
class MealItemData {
  final String id;
  final String categoryName;
  final MealCategory category;
  final String title;
  final String? subtitle;
  final int? calories;
  final bool isRegistered;
  final String? aiBadgeText;
  final String? aiBadgeType; // 'scanned', 'validated'
  final String? imageUrl;
  final IconData? fallbackIcon;
  final String? pendingTag;
  final bool showAddButton;
  final bool showPlusCircle;

  const MealItemData({
    required this.id,
    required this.categoryName,
    required this.category,
    required this.title,
    this.subtitle,
    this.calories,
    this.isRegistered = true,
    this.aiBadgeText,
    this.aiBadgeType,
    this.imageUrl,
    this.fallbackIcon,
    this.pendingTag,
    this.showAddButton = false,
    this.showPlusCircle = false,
  });
}

/// Vitality card representing a registered or pending meal slot
/// (Desayuno, Almuerzo, Merienda, Cena) with AI verification badges or add actions.
class MealCard extends StatelessWidget {
  final MealItemData meal;
  final VoidCallback? onTap;
  final VoidCallback? onAddTap;

  const MealCard({
    super.key,
    required this.meal,
    this.onTap,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:
          '${meal.categoryName}: ${meal.title}. ${meal.calories != null ? "${meal.calories} calorías. " : ""}${meal.isRegistered ? "Registrada" : "Pendiente de registro"}',
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: meal.isRegistered ? onTap : (onAddTap ?? onTap),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: Visual thumbnail / stylized icon badge
                  _buildLeadingVisual(),

                  const SizedBox(width: 14),

                  // Center: Info details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Category Label + Pending Tag (if pending)
                        Row(
                          children: [
                            Text(
                              meal.categoryName.toUpperCase(),
                              style: TextStyle(
                                color: meal.isRegistered
                                    ? AppColors.primaryDark
                                    : AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            if (meal.pendingTag != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  meal.pendingTag!,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 3),

                        // Title
                        Text(
                          meal.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Subtitle
                        if (meal.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            meal.subtitle!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        // AI Verification Badge (for registered meals)
                        if (meal.aiBadgeText != null) ...[
                          const SizedBox(height: 7),
                          _buildAiBadge(),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Right: Calories or Action Button
                  _buildTrailingAction(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingVisual() {
    // If registered and image provided or fallback meal representation
    if (meal.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 58,
          height: 58,
          child: Image.network(
            meal.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildPlaceholderVisual(),
          ),
        ),
      );
    }

    return _buildPlaceholderVisual();
  }

  Widget _buildPlaceholderVisual() {
    Color bgColor;
    Color iconColor;
    IconData icon;

    switch (meal.category) {
      case MealCategory.breakfast:
        bgColor = const Color(0xFFFEF3C7);
        iconColor = const Color(0xFFD97706);
        icon = meal.fallbackIcon ?? Icons.bakery_dining_rounded;
        break;
      case MealCategory.lunch:
        bgColor = const Color(0xFFE8FDF5);
        iconColor = AppColors.primaryDark;
        icon = meal.fallbackIcon ?? Icons.lunch_dining_rounded;
        break;
      case MealCategory.snack:
        bgColor = const Color(0xFFFFEDD5);
        iconColor = const Color(0xFFEA580C);
        icon = meal.fallbackIcon ?? Icons.cookie_outlined;
        break;
      case MealCategory.dinner:
        bgColor = const Color(0xFFEDE9FE);
        iconColor = const Color(0xFF6366F1);
        icon = meal.fallbackIcon ?? Icons.nightlight_round_outlined;
        break;
    }

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          color: iconColor,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildAiBadge() {
    final isValidated = meal.aiBadgeType == 'validated';
    final bgColor = isValidated ? const Color(0xFFF1F5F9) : AppColors.primaryMint;
    final textColor = isValidated ? AppColors.textPrimary : AppColors.primaryDark;
    final iconColor = isValidated ? const Color(0xFF6366F1) : AppColors.primary;
    final icon = isValidated
        ? Icons.verified_rounded
        : Icons.document_scanner_outlined;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isValidated ? AppColors.border : AppColors.primaryBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: iconColor,
          ),
          const SizedBox(width: 4),
          Text(
            meal.aiBadgeText!,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailingAction() {
    if (meal.isRegistered && meal.calories != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${meal.calories} kcal',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      );
    }

    if (meal.showAddButton) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onAddTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 14,
                  color: AppColors.primaryDark,
                ),
                const SizedBox(width: 4),
                const Text(
                  '+ Añadir',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (meal.showPlusCircle) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onAddTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

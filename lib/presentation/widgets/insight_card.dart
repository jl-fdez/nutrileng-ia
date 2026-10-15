import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// AI Insight Card displaying real-time feedback, predictions, and motivational recommendations.
class InsightCard extends StatelessWidget {
  final String text;
  final String badgeText;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const InsightCard({
    super.key,
    this.text =
        'Con tu desayuno actual y café sin azúcar, vas a buen ritmo para mantener tu meta de déficit calórico hoy. 🥑✨',
    this.badgeText = 'NUTRILENS AI INSIGHT • Tiempo real',
    this.icon = Icons.auto_awesome_rounded,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: '$badgeText: $text',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryMint,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryBorder,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI Badge Circular Emblem
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge Headline
                      Text(
                        badgeText.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Message Body
                      Text(
                        text,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                if (onDismiss != null)
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onDismiss,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

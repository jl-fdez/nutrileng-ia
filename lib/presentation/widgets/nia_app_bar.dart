import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// App bar for NutriLens AI (NIA) featuring the brand badge, screen subtitle,
/// streak counter pill, notification bell, and user avatar with active indicator.
class NiaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final int streakDays;
  final VoidCallback? onStreakTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onAvatarTap;
  final String? avatarUrl;
  final bool showActiveIndicator;

  const NiaAppBar({
    super.key,
    this.title = 'NutriLens AI',
    this.subtitle = 'HOY',
    this.streakDays = 7,
    this.onStreakTap,
    this.onNotificationsTap,
    this.onAvatarTap,
    this.avatarUrl,
    this.showActiveIndicator = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.transparent,
        child: Row(
          children: [
            // Left: Brand identity & Screen title
            _buildBrandSection(context),

            const Spacer(),

            // Right: Streak pill + Notification + Avatar
            _buildActionSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandSection(BuildContext context) {
    return Semantics(
      header: true,
      label: '$title, $subtitle',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // NIA Logo Icon / Badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE8FDF5), Color(0xFFD1FAE5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.lens_blur_rounded,
                    color: AppColors.primaryDark,
                    size: 22,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Titles: Brand Name + Subtitle (HOY / SCREEN)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMint,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.primaryBorder, width: 0.8),
                    ),
                    child: const Text(
                      'NIA',
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1),
              Text(
                subtitle.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Streak Badge (e.g. "🔥 7d")
        Semantics(
          button: true,
          label: 'Racha de $streakDays días activos',
          child: InkWell(
            onTap: onStreakTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🔥',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${streakDays}d',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Notification Bell Icon
        Semantics(
          button: true,
          label: 'Notificaciones',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onNotificationsTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // User Avatar with Active Dot
        Semantics(
          button: true,
          label: 'Perfil de usuario',
          child: GestureDetector(
            onTap: onAvatarTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.8),
                    color: AppColors.primaryMint,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: avatarUrl != null
                        ? Image.network(
                            avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _buildAvatarFallback(),
                          )
                        : _buildAvatarFallback(),
                  ),
                ),
                if (showActiveIndicator)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surface,
                          width: 1.8,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      color: const Color(0xFFD1FAE5),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          color: AppColors.primaryDark,
          size: 22,
        ),
      ),
    );
  }
}

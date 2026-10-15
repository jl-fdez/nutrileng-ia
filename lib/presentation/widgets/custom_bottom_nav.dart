import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Floating custom bottom navigation bar with 4 tabs:
/// Hoy, Escanear (prominent center emerald floating button), Historial, and Perfil.
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onScanTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.6),
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Tab 0: Hoy
              _buildNavItem(
                index: 0,
                icon: Icons.sync_rounded,
                activeIcon: Icons.sync_rounded,
                label: 'Hoy',
                semanticsLabel: 'Pestaña Hoy, resumen diario de nutrición',
              ),

              // Tab 1: Escanear (Prominent Floating Emerald Button)
              _buildCenterScanButton(),

              // Tab 2: Historial
              _buildNavItem(
                index: 2,
                icon: Icons.calendar_month_outlined,
                activeIcon: Icons.calendar_month_rounded,
                label: 'Historial',
                semanticsLabel: 'Pestaña Historial, tendencias y comidas pasadas',
              ),

              // Tab 3: Perfil
              _buildNavItem(
                index: 3,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Perfil',
                semanticsLabel: 'Pestaña Perfil, configuración y datos biométricos',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String semanticsLabel,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticsLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 64, minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? activeIcon : icon,
                    color: color,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterScanButton() {
    final isSelected = currentIndex == 1;

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Escanear plato con IA. Reconocimiento fotográfico instantáneo',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (onScanTap != null) {
            onScanTap!();
          } else {
            onTap(1);
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF34D399),
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white,
                  width: 2.5,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.filter_center_focus_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'ESCANEAR',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

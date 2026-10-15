import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Data model representing a recognized food pin in the scanner viewfinder.
class FoodTagPinData {
  final String id;
  final String name;
  final String? portion;
  final int? calories;
  final double relativeX; // 0.0 to 1.0
  final double relativeY; // 0.0 to 1.0
  final Color? accentColor;

  const FoodTagPinData({
    required this.id,
    required this.name,
    this.portion,
    this.calories,
    required this.relativeX,
    required this.relativeY,
    this.accentColor,
  });
}

/// An interactive, animated floating tag pin with a pulsing beacon and glassmorphism pill.
class FoodTagPin extends StatefulWidget {
  final FoodTagPinData data;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showPill;

  const FoodTagPin({
    super.key,
    required this.data,
    this.isSelected = false,
    this.onTap,
    this.showPill = true,
  });

  @override
  State<FoodTagPin> createState() => _FoodTagPinState();
}

class _FoodTagPinState extends State<FoodTagPin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: false);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 2.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.data.accentColor ?? AppColors.primary;
    final portionText = widget.data.portion != null ? ', porción: ${widget.data.portion!}' : '';

    return Semantics(
      button: true,
      label: 'Alimento detectado: ${widget.data.name}$portionText',
      hint: 'Toca para ver detalles o editar este alimento',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: widget.isSelected ? 1.06 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Pill badge
              if (widget.showPill)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.isSelected ? accent : Colors.white.withValues(alpha: 0.3),
                      width: widget.isSelected ? 1.6 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                      if (widget.isSelected)
                        BoxShadow(
                          color: accent.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 0),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.data.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (widget.data.portion != null) ...[
                        Text(
                          ' (${widget.data.portion})',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                      if (widget.data.calories != null) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${widget.data.calories} kcal',
                            style: TextStyle(
                              color: accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

              // Animated Pulsing Beacon Dot
              SizedBox(
                width: 32,
                height: 32,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer expanding ripple
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accent.withValues(
                                alpha: (_scaleAnimation.value * 0.5).clamp(0.0, 1.0),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Middle glow halo
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.8),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.6),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),

                    // Solid Center Core Dot
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

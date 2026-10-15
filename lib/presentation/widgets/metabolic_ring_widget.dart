import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Interactive dual circular metabolic ring widget showing remaining calories,
/// target calories, and complementary cards for consumed and burned calories.
class MetabolicRingWidget extends StatefulWidget {
  final int targetCalories;
  final int consumedCalories;
  final int burnedCalories;
  final int? remainingCalories;
  final VoidCallback? onConsumedTap;
  final VoidCallback? onBurnedTap;

  const MetabolicRingWidget({
    super.key,
    this.targetCalories = 2100,
    this.consumedCalories = 680,
    this.burnedCalories = 340,
    this.remainingCalories,
    this.onConsumedTap,
    this.onBurnedTap,
  });

  @override
  State<MetabolicRingWidget> createState() => _MetabolicRingWidgetState();
}

class _MetabolicRingWidgetState extends State<MetabolicRingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _progressAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant MetabolicRingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.consumedCalories != widget.consumedCalories ||
        oldWidget.targetCalories != widget.targetCalories) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  int get _calculatedRemaining {
    if (widget.remainingCalories != null) {
      return widget.remainingCalories!;
    }
    final rem = widget.targetCalories - widget.consumedCalories;
    return rem < 0 ? 0 : rem;
  }

  double get _consumedRatio {
    if (widget.targetCalories <= 0) return 0.0;
    return (widget.consumedCalories / widget.targetCalories).clamp(0.0, 1.0);
  }

  String _formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final remainingFormatted = _formatNumber(_calculatedRemaining);
    final targetFormatted = _formatNumber(widget.targetCalories);
    final consumedFormatted = _formatNumber(widget.consumedCalories);
    final burnedFormatted = _formatNumber(widget.burnedCalories);

    return Semantics(
      container: true,
      label:
          'Anillo metabólico: $remainingFormatted kilocalorías restantes de una meta de $targetFormatted. $consumedFormatted consumidas y $burnedFormatted quemadas.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular metabolic dual ring
          SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Custom painted dual circular ring with animation
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(240, 240),
                      painter: _MetabolicRingPainter(
                        progress: _consumedRatio * _progressAnimation.value,
                        burnedProgress: (widget.burnedCalories / (widget.targetCalories * 0.5))
                            .clamp(0.0, 1.0) *
                            _progressAnimation.value,
                      ),
                    );
                  },
                ),

                // Center readout typography
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'RESTANTES',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      remainingFormatted,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                        height: 1.1,
                      ),
                    ),
                    const Text(
                      'kcal',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Meta: $targetFormatted',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Two complementary metric cards (Consumidas & Quemadas)
          Row(
            children: [
              // Consumed card
              Expanded(
                child: _buildMetricCard(
                  context: context,
                  title: 'CONSUMIDAS',
                  value: '$consumedFormatted kcal',
                  icon: Icons.restaurant_rounded,
                  iconColor: AppColors.primaryDark,
                  iconBgColor: AppColors.primaryLight,
                  cardBgColor: const Color(0xFFF0FDF4),
                  borderColor: const Color(0xFFDCFCE7),
                  onTap: widget.onConsumedTap,
                ),
              ),
              const SizedBox(width: 12),

              // Burned card
              Expanded(
                child: _buildMetricCard(
                  context: context,
                  title: 'QUEMADAS',
                  value: '$burnedFormatted kcal',
                  icon: Icons.local_fire_department_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  iconBgColor: const Color(0xFFEDE9FE),
                  cardBgColor: const Color(0xFFFAF5FF),
                  borderColor: const Color(0xFFF3E8FF),
                  onTap: widget.onBurnedTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Color cardBgColor,
    required Color borderColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon pill
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),

              // Labels
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
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

/// Custom painter rendering the vital dual circular metabolic ring.
class _MetabolicRingPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final double burnedProgress; // 0.0 to 1.0

  _MetabolicRingPainter({
    required this.progress,
    required this.burnedProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = (size.width / 2) - 12;
    final innerRadius = outerRadius - 16;

    // 1. Base outer background track
    final trackPaint = Paint()
      ..color = const Color(0xFFE6F4EA).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, outerRadius, trackPaint);

    // 2. Inner subtle guide ring
    final innerGuidePaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(center, innerRadius, innerGuidePaint);

    // 3. Active Primary Progress Arc (Consumed)
    if (progress > 0.0) {
      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;

      final rect = Rect.fromCircle(center: center, radius: outerRadius);
      final gradient = SweepGradient(
        startAngle: 0.0,
        endAngle: 2 * math.pi,
        colors: const [
          Color(0xFF059669), // Dark emerald
          Color(0xFF10B981), // Emerald
          Color(0xFF34D399), // Light emerald
          Color(0xFF059669),
        ],
        stops: const [0.0, 0.45, 0.85, 1.0],
        transform: const GradientRotation(-math.pi / 2),
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16.0
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);

      // Subtle glow shadow behind the head of the arc
      final headAngle = startAngle + sweepAngle;
      final headX = center.dx + outerRadius * math.cos(headAngle);
      final headY = center.dy + outerRadius * math.sin(headAngle);

      final glowPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(Offset(headX, headY), 10, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MetabolicRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.burnedProgress != burnedProgress;
  }
}

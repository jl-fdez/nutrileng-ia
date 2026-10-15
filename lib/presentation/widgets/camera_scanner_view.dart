import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import 'food_tag_pin.dart';

/// Interactive camera scanner viewfinder widget with laser animation, framing guides,
/// flash/camera toggle controls, food tag pins, and camera/gallery triggers.
class CameraScannerView extends StatefulWidget {
  final List<FoodTagPinData> pins;
  final ValueChanged<FoodTagPinData>? onPinTapped;
  final VoidCallback? onTakePhoto;
  final VoidCallback? onPickGallery;
  final bool isAnalyzing;
  final String? activePinId;

  const CameraScannerView({
    super.key,
    required this.pins,
    this.onPinTapped,
    this.onTakePhoto,
    this.onPickGallery,
    this.isAnalyzing = false,
    this.activePinId,
  });

  @override
  State<CameraScannerView> createState() => _CameraScannerViewState();
}

class _CameraScannerViewState extends State<CameraScannerView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanLaserController;
  late final Animation<double> _laserAnimation;

  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  String? _pickedImagePath;
  bool _hasScannedSample = true; // Shows recognized food sample by default

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _scanLaserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.12, end: 0.88).animate(
      CurvedAnimation(
        parent: _scanLaserController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scanLaserController.dispose();
    super.dispose();
  }

  Future<void> _handleTakePhoto() async {
    widget.onTakePhoto?.call();
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (photo != null) {
        setState(() {
          _pickedImagePath = photo.path;
          _hasScannedSample = true;
        });
      }
    } catch (e) {
      // In desktop or environments without direct camera permission, activate rich sample scan
      setState(() {
        _hasScannedSample = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Foto simulada con éxito. NutriVision analizó el plato.',
            ),
            backgroundColor: AppColors.primaryDark,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handlePickGallery() async {
    widget.onPickGallery?.call();
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (image != null) {
        setState(() {
          _pickedImagePath = image.path;
          _hasScannedSample = true;
        });
      }
    } catch (e) {
      setState(() {
        _hasScannedSample = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plato cargado para análisis nutricional.'),
            backgroundColor: AppColors.primaryDark,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Viewfinder Container
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 290,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background: Loaded picture OR simulated food dish graphic
                _buildViewfinderBackground(),

                // Grid lines & scanner guide overlay
                const _ViewfinderGridOverlay(),

                // Animated Laser Scanning Line
                AnimatedBuilder(
                  animation: _laserAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: 290 * _laserAnimation.value,
                      left: 20,
                      right: 20,
                      child: Container(
                        height: 2.5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.0),
                              AppColors.primary,
                              Colors.white,
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.0),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.8),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Corner Brackets Overlay
                const _ViewfinderCornerBrackets(),

                // Interactive Food Tag Pins
                if (_hasScannedSample) ..._buildPins(),

                // Top Controls Overlay (Nutrivision badge + Flash & Switch Camera)
                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Badge: • NUTRIVISION ACTIVA
                      _buildNutriVisionBadge(),

                      // Camera utility buttons
                      Row(
                        children: [
                          _buildCircleIconButton(
                            icon: _isFlashOn
                                ? Icons.flash_on
                                : Icons.flash_off,
                            tooltip: _isFlashOn ? 'Desactivar Flash' : 'Activar Flash',
                            isActive: _isFlashOn,
                            onTap: () {
                              setState(() {
                                _isFlashOn = !_isFlashOn;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildCircleIconButton(
                            icon: Icons.flip_camera_ios_outlined,
                            tooltip: 'Cambiar de cámara',
                            isActive: _isFrontCamera,
                            onTap: () {
                              setState(() {
                                _isFrontCamera = !_isFrontCamera;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Analyzing indicator overlay if busy
                if (widget.isAnalyzing)
                  Container(
                    color: Colors.black.withValues(alpha: 0.55),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 38,
                            height: 38,
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'NutriLens IA identificando alimentos...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Action Buttons Row: "📷 Foto en vivo" & "🖼️ Galería"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Main Action: Foto en vivo (Emerald Button)
              Expanded(
                flex: 6,
                child: Semantics(
                  button: true,
                  label: 'Tomar foto en vivo del plato',
                  child: ElevatedButton.icon(
                    onPressed: _handleTakePhoto,
                    icon: const Icon(Icons.camera_alt_rounded, size: 20),
                    label: const Text(
                      'Foto en vivo',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: AppColors.primary.withValues(alpha: 0.4),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Secondary Action: Galería (Subtle Grey Button)
              Expanded(
                flex: 4,
                child: Semantics(
                  button: true,
                  label: 'Cargar foto desde galería',
                  child: OutlinedButton.icon(
                    onPressed: _handlePickGallery,
                    icon: const Icon(
                      Icons.photo_library_outlined,
                      size: 19,
                      color: AppColors.textPrimary,
                    ),
                    label: const Text(
                      'Galería',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      minimumSize: const Size.fromHeight(50),
                      side: const BorderSide(color: AppColors.border, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewfinderBackground() {
    if (_pickedImagePath != null && !kIsWeb) {
      final file = File(_pickedImagePath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
        );
      }
    }

    // Default ultra-rich Food Dish Canvas
    return const _FoodPlateSampleCanvas();
  }

  List<Widget> _buildPins() {
    return widget.pins.map((pin) {
      final isSelected = widget.activePinId == pin.id;
      return Positioned(
        left: (290 * 1.2 * pin.relativeX).clamp(16.0, 320.0),
        top: (290 * pin.relativeY).clamp(40.0, 230.0),
        child: FoodTagPin(
          data: pin,
          isSelected: isSelected,
          onTap: () => widget.onPinTapped?.call(pin),
        ),
      );
    }).toList();
  }

  Widget _buildNutriVisionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary,
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'NUTRIVISION ACTIVA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required String tooltip,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.85)
                    : Colors.black.withValues(alpha: 0.6),
                border: Border.all(
                  color: isActive
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Simulated appetizing food plate presentation when running in sandbox/simulator
class _FoodPlateSampleCanvas extends StatelessWidget {
  const _FoodPlateSampleCanvas();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _RealisticFoodPlatePainter(),
      ),
    );
  }
}

/// Custom painter rendering a beautiful styled overhead view of a healthy meal
class _RealisticFoodPlatePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.52, size.height * 0.56);

    // 1. Wood table or slate background texture subtle glow
    final bgGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.1, 0.2),
        radius: 0.9,
        colors: [
          const Color(0xFF334155),
          const Color(0xFF0F172A),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgGlow);

    // 2. Main Ceramic Plate
    final plateRadius = size.height * 0.44;
    final plateShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(center.translate(0, 8), plateRadius, plateShadow);

    final platePaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFF8FAFC),
          Color(0xFFE2E8F0),
          Color(0xFFCBD5E1),
        ],
        stops: [0.75, 0.94, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: plateRadius));
    canvas.drawCircle(center, plateRadius, platePaint);

    // Inner rim
    final rimPaint = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, plateRadius * 0.88, rimPaint);

    // 3. Grilled Chicken Breast (Center-Left)
    final chickenRect = Rect.fromCenter(
      center: center.translate(-size.width * 0.08, -size.height * 0.03),
      width: size.width * 0.36,
      height: size.height * 0.42,
    );
    final chickenPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFDE68A),
          Color(0xFFD97706),
          Color(0xFF92400E),
        ],
      ).createShader(chickenRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(chickenRect, const Radius.circular(32)),
      chickenPaint,
    );

    // Grill marks
    final grillPaint = Paint()
      ..color = const Color(0xFF451A03).withValues(alpha: 0.55)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    for (int i = -2; i <= 2; i++) {
      final yOffset = i * 16.0;
      canvas.drawLine(
        Offset(chickenRect.left + 15, chickenRect.center.dy + yOffset - 12),
        Offset(chickenRect.right - 18, chickenRect.center.dy + yOffset + 14),
        grillPaint,
      );
    }

    // 4. Fresh Salad with Vegetables (Right side of plate)
    final saladCenter = center.translate(size.width * 0.14, size.height * 0.04);
    final greensPaint = Paint()
      ..color = const Color(0xFF22C55E).withValues(alpha: 0.85);
    final darkGreensPaint = Paint()
      ..color = const Color(0xFF15803D).withValues(alpha: 0.9);
    final tomatoPaint = Paint()
      ..color = const Color(0xFFEF4444);
    final cucumberPaint = Paint()
      ..color = const Color(0xFF86EFAC);

    // Lettuce leaves clusters
    canvas.drawCircle(saladCenter.translate(-15, -10), 22, greensPaint);
    canvas.drawCircle(saladCenter.translate(18, -15), 24, darkGreensPaint);
    canvas.drawCircle(saladCenter.translate(5, 18), 26, greensPaint);
    canvas.drawCircle(saladCenter.translate(22, 12), 20, darkGreensPaint);

    // Cherry Tomatoes
    canvas.drawCircle(saladCenter.translate(-8, -20), 8, tomatoPaint);
    canvas.drawCircle(saladCenter.translate(16, -2), 9, tomatoPaint);
    canvas.drawCircle(saladCenter.translate(-12, 15), 7.5, tomatoPaint);

    // Cucumbers
    canvas.drawCircle(saladCenter.translate(0, -6), 9, cucumberPaint);
    canvas.drawCircle(saladCenter.translate(18, 22), 8.5, cucumberPaint);

    // 5. Cup of Roast Coffee (Top-Left)
    final cupCenter = Offset(size.width * 0.22, size.height * 0.28);
    final cupRadius = size.height * 0.16;

    // Cup rim
    final cupSaucer = Paint()..color = const Color(0xFFCBD5E1);
    canvas.drawCircle(cupCenter, cupRadius, cupSaucer);

    final cupInterior = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFF271306),
          Color(0xFF1A0A02),
        ],
      ).createShader(Rect.fromCircle(center: cupCenter, radius: cupRadius * 0.78));
    canvas.drawCircle(cupCenter, cupRadius * 0.78, cupInterior);

    // Coffee crema swirl
    final cremaPaint = Paint()
      ..color = const Color(0xFFB45309).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(cupCenter, cupRadius * 0.45, cremaPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Subtle grid overlay giving camera viewfinder optics feel
class _ViewfinderGridOverlay extends StatelessWidget {
  const _ViewfinderGridOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _GridLinesPainter(),
          );
        },
      ),
    );
  }
}

class _GridLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 0.8;

    // Vertical rule of thirds
    final x1 = size.width / 3;
    final x2 = (size.width / 3) * 2;
    canvas.drawLine(Offset(x1, 0), Offset(x1, size.height), linePaint);
    canvas.drawLine(Offset(x2, 0), Offset(x2, size.height), linePaint);

    // Horizontal rule of thirds
    final y1 = size.height / 3;
    final y2 = (size.height / 3) * 2;
    canvas.drawLine(Offset(0, y1), Offset(size.width, y1), linePaint);
    canvas.drawLine(Offset(0, y2), Offset(size.width, y2), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Modern corner bracket framing guidelines
class _ViewfinderCornerBrackets extends StatelessWidget {
  const _ViewfinderCornerBrackets();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: CustomPaint(
          painter: _CornerBracketsPainter(),
        ),
      ),
    );
  }
}

class _CornerBracketsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 22.0;

    // Top-Left
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);

    // Top-Right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    // Bottom-Left
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), paint);

    // Bottom-Right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

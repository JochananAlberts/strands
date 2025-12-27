import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_screen.dart';
import 'dart:ui'; // For PathMetrics
import 'main_menu_screen.dart';
import 'app_theme.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with TickerProviderStateMixin {
  late AnimationController _appearController;
  late AnimationController _lineController;
  late Animation<double> _lineAnimation;
  
  // L I S A
  final List<String> letters = ['L', 'I', 'S', 'A'];
  // Grid layout: 2x2
  // L I
  // S A
  // Positions relative to center
  final double spacing = 100.0;
  
  @override
  void initState() {
    super.initState();
    
    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _lineController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500)
    );
    
    _lineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.easeInOut)
    );

    _startSequence();
  }
  
  Future<void> _startSequence() async {
    // 1. Letters appear one by one
    await _appearController.forward();
    
    // 2. Line draws
    await _lineController.forward();
    
    // 3. Pause then navigate
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainMenuScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _appearController.dispose();
    _lineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SizedBox(
          width: spacing * 2,
          height: spacing * 2,
          child: Stack(
            children: [
              // Draw the line
              AnimatedBuilder(
                animation: _lineAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(spacing * 2, spacing * 2),
                    painter: _IntroLinePainter(progress: _lineAnimation.value),
                  );
                },
              ),
              // Letters
              _buildLetter(0, 'L', Alignment.topLeft),
              _buildLetter(1, 'I', Alignment.topRight),
              _buildLetter(2, 'S', Alignment.bottomLeft),
              _buildLetter(3, 'A', Alignment.bottomRight),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLetter(int index, String char, Alignment alignment) {
    // Staggered appearance
    // Total duration 1200ms. 4 items.
    // 0.0-0.25, 0.25-0.5, etc.
    double start = index * 0.25;
    double end = start + 0.25;
    
    Animation<double> opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _appearController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
    
    Animation<double> scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _appearController,
        curve: Interval(start, end, curve: Curves.elasticOut),
      ),
    );

    return Align(
      alignment: alignment,
      child: AnimatedBuilder(
        animation: _appearController,
        builder: (context, child) {
          return Opacity(
            opacity: opacity.value,
            child: Transform.scale(
              scale: scale.value,
              child: Container(
                width: 70, // Slightly larger
                height: 70,
                decoration: BoxDecoration(
                  color: AppTheme.primary, // Icon style typically vibrant
                  borderRadius: BorderRadius.circular(20), // Rounded
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.textDark.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  char,
                  style: GoogleFonts.kanit(
                    fontSize: 40, 
                    fontWeight: FontWeight.w900,
                    color: AppTheme.background, // was white
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _IntroLinePainter extends CustomPainter {
  final double progress;
  _IntroLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = AppTheme.primary // Or Lisa's game colors
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Define points based on alignment logic in build
    // Box is size x size.
    // Letters are at corners.
    // Each letter box is 60x60 centered at corners?
    // Align(topLeft) puts the 60x60 box at 0,0. Center is 30,30.
    
    double offset = 30; // Half of letter box
    final p1 = Offset(offset, offset); // L (Top Left)
    final p2 = Offset(size.width - offset, offset); // I (Top Right)
    final p3 = Offset(offset, size.height - offset); // S (Bottom Left)
    final p4 = Offset(size.width - offset, size.height - offset); // A (Bottom Right)
    
    // Path: L -> I -> S -> A
    // Segments: 
    // 1. L->I (Horizontal)
    // 2. I->S (Diagonal)
    // 3. S->A (Horizontal)
    
    // We need a path that visits p1 -> p2 -> p3 -> p4 but rounds the corners at p2 and p3.
    // However, for proper animation progress, we need to calculate the full rounded path first, 
    // then extract the sub-path based on progress.
    
    Path fullPath = Path();
    fullPath.moveTo(p1.dx, p1.dy);
    
    // Corner radius
    double radius = 30.0;
    
    // Segment 1: L -> I (p1 -> p2)
    // We stop 'radius' short of p2
    // But we need to be careful if segments are too short. spacing=100, box=200. Distance is plenty.
    
    // Direction p1->p2 is (1, 0)
    // Direction p2->p3 is diagonal
    // Direction p3->p4 is (1, 0)
    
    // To round corner at p2:
    // Go from p1 to (p2 - radius towards p1)
    // curve to (p2 + radius towards p3) using p2 as control?
    // p2 is sharp turn.
    
    // Simple approach:
    // 1. Line to slightly before p2.
    // 2. Quadratic to slightly after p2 (on line to p3).
    
    // Vector math helpers would be nice, but let's do simple approximations for this fixed layout.
    // p1 = (30,30), p2 = (170, 30)
    // p3 = (30, 170), p4 = (170, 170)
    
    // Corner 1 (at p2): Incoming Horizontal, Outgoing Diagonal (Back-Left-Downish)
    // Wait, p1->p2 is Right. p2->p3 is Left-Down diagonal.
    
    // Calculate intermediate points for Rounding
    // P2_in: on line p1-p2, radius away from p2.
    // P2_out: on line p2-p3, radius away from p2.
    
    Offset dir12 = (p2 - p1) / (p2 - p1).distance;
    Offset dir23 = (p3 - p2) / (p3 - p2).distance;
    Offset dir34 = (p4 - p3) / (p4 - p3).distance;
    
    Offset p2_in = p2 - dir12 * radius;
    Offset p2_out = p2 + dir23 * radius;
    
    Offset p3_in = p3 - dir23 * radius;
    Offset p3_out = p3 + dir34 * radius;
    
    fullPath.lineTo(p2_in.dx, p2_in.dy);
    fullPath.quadraticBezierTo(p2.dx, p2.dy, p2_out.dx, p2_out.dy);
    
    fullPath.lineTo(p3_in.dx, p3_in.dy);
    fullPath.quadraticBezierTo(p3.dx, p3.dy, p3_out.dx, p3_out.dy);
    
    fullPath.lineTo(p4.dx, p4.dy);
    
    // Now trim path based on progress
    // PathMetrics helps us exact length
    
    // Actually, CustomPainter has access to metrics.
    // We can use extractPath.
    
    var metrics = fullPath.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      var metric = metrics.first;
      double len = metric.length;
      Path drawPath = metric.extractPath(0, len * progress);
      canvas.drawPath(drawPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _IntroLinePainter old) => old.progress != progress;
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_screen.dart';

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
          pageBuilder: (_, __, ___) => const GameScreen(),
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
      backgroundColor: Colors.white,
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
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  // No box decoration to look cleaner, just text? 
                  // Or simulated cell looks nice.
                  // Let's match the game style roughly but cleaner for intro.
                ),
                alignment: Alignment.center,
                child: Text(
                  char,
                  style: GoogleFonts.kanit(
                    fontSize: 40, 
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
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
      ..color = Colors.blueAccent // Or Lisa's game colors
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
    
    Path path = Path();
    path.moveTo(p1.dx, p1.dy);
    
    // Total path length roughly
    double d1 = (p2 - p1).distance;
    double d2 = (p3 - p2).distance;
    double d3 = (p4 - p3).distance;
    double totalDist = d1 + d2 + d3;
    
    double currentDist = totalDist * progress;
    
    // Draw segment 1
    if (currentDist <= d1) {
      // Interpolate p1 to p2
      double t = currentDist / d1;
      Offset target = Offset.lerp(p1, p2, t)!;
      path.lineTo(target.dx, target.dy);
    } else {
      path.lineTo(p2.dx, p2.dy);
      double distAfter1 = currentDist - d1;
      
      // Draw segment 2
      if (distAfter1 <= d2) {
        double t = distAfter1 / d2;
        Offset target = Offset.lerp(p2, p3, t)!;
        path.lineTo(target.dx, target.dy);
      } else {
        path.lineTo(p3.dx, p3.dy);
        double distAfter2 = distAfter1 - d2;
        
        // Draw segment 3
        if (distAfter2 <= d3) {
           double t = distAfter2 / d3;
           Offset target = Offset.lerp(p3, p4, t)!;
           path.lineTo(target.dx, target.dy);
        } else {
           path.lineTo(p4.dx, p4.dy);
        }
      }
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _IntroLinePainter old) => old.progress != progress;
}

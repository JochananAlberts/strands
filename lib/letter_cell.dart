import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LetterCell extends StatefulWidget {
  final String char;
  final bool isSelected;
  final bool isFound;
  final bool isSpangram;
  final bool isHinted;
  final int animationOrder;
  final int animationTotalLength;

  const LetterCell({
    super.key,
    required this.char,
    required this.isSelected,
    required this.isFound,
    this.isSpangram = false,
    this.isHinted = false,
    this.animationOrder = -1,
    this.animationTotalLength = 0,
  });

  @override
  State<LetterCell> createState() => _LetterCellState();
}

class _LetterCellState extends State<LetterCell> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Pop duration
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void didUpdateWidget(LetterCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if we should animate
    // Condition: we just became found, AND we have a valid animation order
    if (widget.isFound && !oldWidget.isFound && widget.animationOrder >= 0) {
      _triggerSnakeAnimation();
    }
  }
  
  Future<void> _triggerSnakeAnimation() async {
    // "Snake-like motion from start to end and then back again"
    // Forward pass delay
    int forwardDelay = widget.animationOrder * 100; // 100ms per letter
    
    await Future.delayed(Duration(milliseconds: forwardDelay));
    if (!mounted) return;
    await _controller.forward();
    await _controller.reverse();
    
    // Backward pass delay
    // Total forward time = L * 100.
    // Backward starts after forward finishes? Or continuous?
    // "start to end and then back again"
    // Let's make it reflect immediately. 
    // Wait for the wave to reach the end, then reflect.
    // Time until reflection = (TotalLength - 1 - Order) * 100.
    // Total wait from start of FIRST animation = (TotalLength - 1) * 100 * 2?
    
    // Simpler: Just calculate the timestamp for the return trip relative to NOW.
    // Current time is T0 + forwardDelay.
    // Wave hits end at T0 + (L-1)*100.
    // Wave returns to me at T0 + (L-1)*100 + (L-1 - Order)*100.
    
    int totalLen = widget.animationTotalLength;
    if (totalLen > 0) {
       int timeToHitEnd = (totalLen - 1 - widget.animationOrder) * 100;
       int timeReturn = timeToHitEnd + (totalLen - 1 - widget.animationOrder) * 100; 
       
       // Just wait the difference
       // We just played (300ms + 300ms) = 600ms animation? No, scale up/down is fast.
       // Let's assume the "pop" is the event.
       
       // Correct math:
       // Forward wave hits me at T(start).
       // Backward wave hits me later.
       // The delay between my first pop and second pop is 2 * (L - 1 - Order) * 100.
       
       int returnDelay = 2 * (totalLen - 1 - widget.animationOrder) * 100;
       // Add a small buffer so it doesn't overlap weirdly if close
       if (returnDelay > 200) {
          await Future.delayed(Duration(milliseconds: returnDelay - 300)); // Subtract animation duration
          if (!mounted) return;
          await _controller.forward();
          await _controller.reverse();
       }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Style logic
    Color textColor = Colors.black;
    FontWeight fontWeight = FontWeight.w500;
    
    if (widget.isFound) {
      textColor = widget.isSpangram ? Colors.amber[800]! : Colors.blue[600]!;
      fontWeight = FontWeight.bold;
    } else if (widget.isSelected) {
      textColor = Colors.black;
      fontWeight = FontWeight.bold;
    }
    
    // Hint visual wrapper
    Widget content = ScaleTransition(
      scale: _scaleAnimation,
      child: Text(
        widget.char,
        style: GoogleFonts.kanit(
          fontSize: 32,
          fontWeight: fontWeight,
          color: textColor,
        ),
      ),
    );
    
    if (widget.isHinted && !widget.isFound) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.yellowAccent.withOpacity(0.8), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.yellowAccent.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(child: content),
      );
    }

    return Center(
      child: content,
    );
  }
}

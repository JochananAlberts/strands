import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LetterCell extends StatelessWidget {
  final String char;
  final bool isSelected;
  final bool isFound;
  final bool isSpangram;
  final bool isHinted;

  const LetterCell({
    super.key,
    required this.char,
    required this.isSelected,
    required this.isFound,
    this.isSpangram = false,
    this.isHinted = false,
  });

  @override
  Widget build(BuildContext context) {
    // Style logic
    Color textColor = Colors.black;
    FontWeight fontWeight = FontWeight.w500;
    
    if (isFound) {
      textColor = isSpangram ? Colors.amber[800]! : Colors.blue[600]!;
      fontWeight = FontWeight.bold;
    } else if (isSelected) {
      textColor = Colors.black;
      fontWeight = FontWeight.bold;
    }
    
    // Hint visual wrapper
    Widget content = Text(
      char,
      style: GoogleFonts.kanit(
        fontSize: 32,
        fontWeight: fontWeight,
        color: textColor,
      ),
    );
    
    if (isHinted && !isFound) {
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

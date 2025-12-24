import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LetterCell extends StatelessWidget {
  final String char;
  final bool isSelected;
  final bool isFound;
  final bool isSpangram;

  const LetterCell({
    super.key,
    required this.char,
    required this.isSelected,
    required this.isFound,
    this.isSpangram = false,
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
      textColor = Colors.black; // Selected usually just has a line over it, text remains black or becomes bold
      fontWeight = FontWeight.bold;
    }

    return Center(
      child: Text(
        char,
        style: GoogleFonts.kanit( // Using Kanit or similar blocky font
          fontSize: 32,
          fontWeight: fontWeight,
          color: textColor,
        ),
      ),
    );
  }
}

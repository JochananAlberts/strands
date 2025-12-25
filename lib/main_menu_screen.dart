import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemNavigator
import 'package:google_fonts/google_fonts.dart';
import 'game_screen.dart'; // No longer direct, but maybe needed for other things? kept for safety, or remove if unused.
import 'level_select_screen.dart';
import 'package:provider/provider.dart';
import 'game_model.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              "Lisa's Games",
              style: GoogleFonts.kanit(
                fontSize: 48, // Large title
                fontWeight: FontWeight.w900,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 60),

            // Play Button
            _buildMenuButton(
              context,
              label: "STRINGS",
              color: Colors.blueAccent,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LevelSelectScreen())
                );
              }
            ),
            const SizedBox(height: 20),

            // Maps Button
            _buildMenuButton(
              context,
              label: "MAPS",
              color: Colors.amber,
              onPressed: () {
                // Future implementation
              },
            ),
            const SizedBox(height: 20),

            // Exit Button
            _buildMenuButton(
              context,
              label: "EXIT",
              color: Colors.grey,
              onPressed: () {
                SystemNavigator.pop(); // Closes the app
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, {
    required String label, 
    required Color color, 
    required VoidCallback onPressed
  }) {
    return SizedBox(
      width: 200,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: GoogleFonts.kanit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

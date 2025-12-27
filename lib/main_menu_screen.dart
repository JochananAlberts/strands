import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemNavigator
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';
 
import 'level_select_screen.dart';
// Provider and game_model are not used here currently

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
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
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 60),

            // Play Button
            _buildMenuButton(
              context,
              label: "STRINGS",
              color: AppTheme.primary,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LevelSelectScreen())
                );
              }
            ),
            const SizedBox(height: 20),

            // Maps Button

            const SizedBox(height: 20),

            // Exit Button
            _buildMenuButton(
              context,
              label: "EXIT",
              color: AppTheme.disabled,
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
          foregroundColor: AppTheme.background, // White text on buttons
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

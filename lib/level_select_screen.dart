import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'game_model.dart';
import 'game_screen.dart';
import 'level_data.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "SELECT PUZZLE",
          style: GoogleFonts.kanit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, // Single column
            childAspectRatio: 5.0, // adjusted to keep height similar (width increased by 2x, so ratio increased by 2x)
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: LevelData.levels.length,
          itemBuilder: (context, index) {
            final level = LevelData.levels[index];
            return _buildLevelButton(context, index, level.theme);
          },
        ),
      ),
    );
  }

  Widget _buildLevelButton(BuildContext context, int index, String theme) {
    return ElevatedButton(
      onPressed: () {
        // Load the level and navigate
        Provider.of<GameModel>(context, listen: false).loadLevel(index);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GameScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[50]!.withOpacity(0.5),
        foregroundColor: Colors.black87,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.blue[200]!, width: 2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: Text(
        "${index + 1}. $theme",
        textAlign: TextAlign.center,
        style: GoogleFonts.kanit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

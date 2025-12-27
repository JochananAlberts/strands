import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'game_model.dart';
import 'game_screen.dart';
import 'level_data.dart';
import 'app_theme.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          "SELECT PUZZLE",
          style: GoogleFonts.kanit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textMain,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textMain),
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
    // Access score
    final game = Provider.of<GameModel>(context);
    int? bestTime = game.levelHighScores[index];
    
    // Default Style (Not started / No score)
    Color bgColor = AppTheme.primaryLight.withOpacity(0.5);
    Color borderColor = AppTheme.primaryBorder;
    List<Widget> medals = [];
    
    if (bestTime != null) {
      // Completed Style (Green box for everyone who finished)
      bgColor = AppTheme.successBg.withOpacity(0.5);
      borderColor = AppTheme.successBorder;
      
      // Cumulative Medal Logic
      // If < 60s (1 min), you get Gold, Silver, AND Bronze
      if (bestTime < 60) {
        medals.add(const Icon(Icons.workspace_premium, color: AppTheme.medalGold, size: 24)); // Gold
      }
      
      // If < 120s (2 mins), you get Silver AND Bronze
      if (bestTime < 120) {
        medals.add(const Icon(Icons.workspace_premium, color: AppTheme.medalSilver, size: 24)); // Silver
      }
      
      // If < 300s (5 mins), you get Bronze
      if (bestTime < 300) {
        medals.add(const Icon(Icons.workspace_premium, color: AppTheme.medalBronze, size: 24)); // Bronze
      }
    }

    return ElevatedButton(
      onPressed: () {
        // Load the level and navigate
        game.loadLevel(index);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GameScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: AppTheme.textMain,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Level Text
          Expanded(
              child: Text(
                "${index + 1}. $theme",
                textAlign: TextAlign.center,
                style: GoogleFonts.kanit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ),
          // Medal Icons
          if (medals.isNotEmpty) ...[
             const SizedBox(width: 8),
             Row(
               mainAxisSize: MainAxisSize.min,
               children: medals,
             ),
          ]
        ],
      ),
    );
  }
}

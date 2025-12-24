import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_model.dart';
import 'grid_board.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Strands Clone",
          style: GoogleFonts.kanit(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black),
            onPressed: () {
              // Show rules
            },
          )
        ],
      ),
      body: Consumer<GameModel>(
        builder: (context, game, child) {
          return Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TODAY'S THEME",
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      game.theme,
                      style: GoogleFonts.kanit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Progress? Words found / Total?
                    Text(
                      "Found ${game.foundWords.length} of ${game.solutions.length}",
                       style: GoogleFonts.roboto(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              
              const Expanded(
                child: Center(
                  child: game.isLoading 
                    ? const Center(child: CircularProgressIndicator()) 
                    : const AspectRatio(
                        aspectRatio: 6/8, // The grid is 6x8
                        child: GridBoard(),
                      ),
                ),
              ),
              
              // Bottom area (Hints, etc - simplified)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: game.isGameWon 
                  ? Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "PUZZLE COMPLETE!",
                            style: GoogleFonts.kanit(
                              fontSize: 20, 
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => game.nextLevel(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                          child: Text(
                            "Next Level",
                             style: GoogleFonts.kanit(fontSize: 18),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
    );
  }
}

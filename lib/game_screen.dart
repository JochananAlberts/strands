import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_model.dart';
import 'grid_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Secret pass state
  int _hintTapCount = 0;
  DateTime? _lastTapTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Reset Button (Upper Left)
        leading: IconButton(
          icon: const Icon(Icons.refresh, color: Colors.black),
          onPressed: () {
            // Confirm reset? Or just do it. Simple alert is safer.
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Reset Puzzle?"),
                content: const Text("This will clear your current progress for this level."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                       Provider.of<GameModel>(context, listen: false).resetLevel();
                       Navigator.pop(ctx);
                    },
                    child: const Text("Reset"),
                  ),
                ],
              ),
            );
          },
        ),
        title: Text(
          "Lisa's Game",
          style: GoogleFonts.kanit(
            fontSize: 28, // Increased size
            fontWeight: FontWeight.bold, 
            color: Colors.black
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [], // Removed help button
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
                    // Removed "Today's Theme" text
                    Text(
                      game.theme,
                      style: GoogleFonts.kanit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Removed progress text from here
                  ],
                ),
              ),
              
              Expanded(
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
                  : Stack(
                      children: [
                        // Hint Bulb (Bottom Left)
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 24.0, bottom: 48.0), 
                            child: _buildHintBulb(game),
                          ),
                        ),
                        // Progress Text (Bottom Right)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 24.0, bottom: 56.0),
                            child: Text(
                              "Found ${game.foundWords.length} of ${game.solutions.length}",
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700]
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
              ),
            ],
          );
        },
      ),
    );
  }

    Widget _buildHintBulb(GameModel game) {
    // Determine state
    double progress = game.hintProgress; // 0.0 to 1.0 (clamped)
    bool isFull = game.isHintActive;
    
    // Aesthetic mapping
    Color bulbColor;
    double iconSize = 48;
    List<BoxShadow> shadows = [];

    if (progress == 0) {
      bulbColor = Colors.grey[400]!;
    } else if (isFull) {
      bulbColor = Colors.yellowAccent[700]!; // Bright!
      // Glow effect
      shadows = [
        BoxShadow(
          color: Colors.yellowAccent.withOpacity(0.6),
          blurRadius: 20,
          spreadRadius: 5,
        ),
        BoxShadow(
          color: Colors.orangeAccent.withOpacity(0.4),
          blurRadius: 40,
          spreadRadius: 10,
        ),
      ];
    } else {
      // 1..4 range logic (or whatever steps)
      // Interpolate from dim yellow to fuller yellow
      // e.g. 200 -> 600
      bulbColor = Color.lerp(Colors.yellow[100]!, Colors.yellow[600]!, progress)!;
    }

    return GestureDetector(
      onTap: () {
         // Secret Cheat: 5 taps to solve
         DateTime now = DateTime.now();
         if (_lastTapTime == null || now.difference(_lastTapTime!) < const Duration(milliseconds: 500)) {
            _hintTapCount++;
         } else {
            _hintTapCount = 1;
         }
         _lastTapTime = now;
         
         if (_hintTapCount >= 5) {
            debugPrint("Cheat activated: Solving puzzle");
            game.solveAll();
            _hintTapCount = 0;
            return;
         }

         // If game is won, next click goes to next level (User request: "clicking on the light bolb another time continue")
         if (game.isGameWon) {
           game.nextLevel();
           return;
         }
      
         if (isFull && game.hintedWord == null) {
            game.consumeHint();
         }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: shadows,
        ),
        child: Icon(
          Icons.lightbulb,
          color: bulbColor,
          size: iconSize,
        ),
      ),
    );
  }
}

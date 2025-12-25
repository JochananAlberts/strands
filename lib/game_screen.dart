import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_model.dart';
import 'grid_board.dart';
import 'main_menu_screen.dart';
import 'dart:math'; // For random
import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart'; // Accelerometer
import 'dart:math' as math; // For abs

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  // Secret pass state
  int _hintTapCount = 0;
  DateTime? _lastTapTime;
  
  // Timer state
  Timer? _timer;
  String _timeString = "00:00";

  // Shake detection state
  StreamSubscription<UserAccelerometerEvent>? _accelSubscription;
  int _shakeCount = 0;
  DateTime? _lastShakeTime;
  static const int _requiredShakes = 3; 
  static const double _shakeThreshold = 10.0; // m/s^2
  static const Duration _shakeTimeout = Duration(seconds: 2); // Reset if too slow between shakes
  static const Duration _shakeDebounce = Duration(milliseconds: 200); // Prevent duplicates

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
       Provider.of<GameModel>(context, listen: false).startTimer();
    });
    _startUiTimer();
    _initShakeSensor();
  }
  
  void _initShakeSensor() {
    try {
      _accelSubscription = userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
        // Shaking left-to-right primarily affects the X axis.
        // We look for significant acceleration on X.
        
        if (event.x.abs() > _shakeThreshold) {
           _handleShakeInput();
        }
      });
    } catch (e) {
      debugPrint("Sensor error: $e");
    }
  }
  
  void _handleShakeInput() {
    final now = DateTime.now();
    
    // Debounce (prevent one big shake counting as 50 events)
    if (_lastShakeTime != null && now.difference(_lastShakeTime!) < _shakeDebounce) {
      return;
    }
    
    // Timeout
    if (_lastShakeTime != null && now.difference(_lastShakeTime!) > _shakeTimeout) {
      _shakeCount = 0;
    }
    
    _shakeCount++;
    _lastShakeTime = now;
    debugPrint("Shake detected! Count: $_shakeCount");
    
    if (_shakeCount >= _requiredShakes) {
      _triggerSensorHint();
      _shakeCount = 0;
    }
  }
  
  void _triggerSensorHint() {
    final game = Provider.of<GameModel>(context, listen: false);
    if (!game.isGameWon) {
       // User request: No message, just hint.
       game.consumeHint(force: true);
    }
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final game = Provider.of<GameModel>(context, listen: false);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      game.stopTimer();
    } else if (state == AppLifecycleState.resumed) {
      if (ModalRoute.of(context)?.isCurrent ?? true) {
         game.startTimer();
      }
    }
  }
  
  void _startUiTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      _updateTime();
    });
  }
  
  void _updateTime() {
    final game = Provider.of<GameModel>(context, listen: false);
    if (game.isLoading) return;
    
    if (game.isGameWon) {
       game.stopTimer(); // Ensure stopped if won 
       return; 
    }
    
    // Self-heal race condition: If game is valid but timer stopped, start it.
    // However, don't start it if we are paused (like in menu).
    // We can rely on lifecycle for "paused" app state, but meant for "in-game paused".
    // For now, let's assume if we are on this screen and not loading/won, it should run.
    // BUT we need to handle the menu pause.
    // If a dialog is open, this timer still ticks!
    // We should check if ModalRoute.of(context)?.isCurrent ?? true
    // If a dialog is pushed, isCurrent is false.
    bool isTop = ModalRoute.of(context)?.isCurrent ?? true;
    if (isTop) {
       if (!game.isTimerRunning) {
          game.startTimer();
       }
    } else {
       // Dialog open, paused?
       // If we rely on _showGameMenu stopping it, then _updateTime continues but sees stopped timer.
       // We just update the string.
    }
    
    int totalSeconds = game.totalSecondsPlayed;
    final minutes = (totalSeconds ~/ 60).remainder(60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    
    setState(() {
      _timeString = "$minutes:$seconds";
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _accelSubscription?.cancel();
    // Stop timer when leaving screen
    try {
      Provider.of<GameModel>(context, listen: false).stopTimer();
    } catch (e) {
      // access might fail if context unsafe?
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Menu Button (Upper Left)
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => _showGameMenu(context),
        ),
        title: Text(
          Provider.of<GameModel>(context).isLoading ? "" : Provider.of<GameModel>(context).theme,

          style: GoogleFonts.kanit(
            fontSize: 28, // Increased size
            fontWeight: FontWeight.bold, 
            color: Colors.black
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
           // Timer Display
           Center(
             child: Padding(
               padding: const EdgeInsets.only(right: 16.0),
               child: Text(
                 _timeString, 
                 style: GoogleFonts.robotoMono(
                   fontSize: 18, 
                   fontWeight: FontWeight.bold, 
                   color: Colors.black54
                 ),
               ),
             ),
           ),
        ], 
      ),
      body: Consumer<GameModel>(
        builder: (context, game, child) {
          if (game.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              // Header - Current Word Preview
              Container(
                height: 60, // Fixed height to prevent jumpiness
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  game.currentWordBeingFormed,
                  style: GoogleFonts.kanit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent, 
                  ),
                ),
              ),
              
              Expanded(
                child: Center(
                  child: game.isLoading 
                    ? const Center(child: CircularProgressIndicator()) 
                    : game.isGameWon
                        ? Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: _buildVictoryView(context, game),
                          )
                        : const AspectRatio(
                            aspectRatio: 6/8, // The grid is 6x8
                            child: GridBoard(),
                          ),
                ),
              ),
              
              // Bottom area (Hints, etc)
              if (!game.isGameWon)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Stack(
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

  Future<void> _showGameMenu(BuildContext context) async {
    final game = Provider.of<GameModel>(context, listen: false);
    game.stopTimer(); // Pause
    
    // Fetch High Score
    int? highScore = await game.getHighScore(game.currentLevelIndex);
    String highScoreText = "Nothing";
    if (highScore != null) {
      final m = (highScore ~/ 60).remainder(60).toString().padLeft(2, '0');
      final s = (highScore % 60).toString().padLeft(2, '0');
      highScoreText = "$m:$s";
    }
    
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "MENU",
                style: GoogleFonts.kanit(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Best Time: $highScoreText",
                  style: GoogleFonts.robotoMono(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700]
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Quote Option
              // Quote Option REMOVED
              
              const SizedBox(height: 16),

              // Reset Option
              _buildMenuOption(
                icon: Icons.refresh,
                label: "Reset Level",
                color: Colors.blueAccent,
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmReset(context);
                },
              ),
              
              const SizedBox(height: 16),

              // Home Option
              _buildMenuOption(
                icon: Icons.home,
                label: "Home Screen",
                color: Colors.grey,
                onTap: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.of(context).pushReplacement(
                     MaterialPageRoute(builder: (_) => const MainMenuScreen())
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
    
    // Resume if still mounted and not won
    if (mounted && !game.isGameWon) {
       // Only resume if we are still the top route (didn't go Home)
       if (ModalRoute.of(context)?.isCurrent ?? false) {
          game.startTimer();
       }
    }
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
         // Only active if EXACTLY ONE bonus word is found (per user request)
         if (game.currentProgress == 1) {
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



  Widget _buildMenuOption({
    required IconData icon, 
    required String label, 
    required Color color, 
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.kanit(fontSize: 18, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
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
                setState(() { _timeString = "00:00"; });
                Navigator.pop(ctx);
            },
            child: const Text("Reset", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Quote cache
  String? _cachedQuote;

  Widget _buildVictoryView(BuildContext context, GameModel game) {
    if (_cachedQuote == null) {
      _cachedQuote = Random().nextBool() 
          ? "Pain is weakness leaving the body" 
          : "Pain is Progress";
    }

    // Format time
    int total = game.totalSecondsPlayed;
    final m = (total ~/ 60).remainder(60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    String timeText = "$m:$s";

    // Format Rank
    String rankText = "Completed";
    Color rankColor = Colors.grey;
    if (game.currentRunRank != null) {
        if (game.currentRunRank == 1) {
            rankText = "🏆 New Record! (1st Place)";
            rankColor = Colors.green[700]!;
        } else if (game.currentRunRank! <= 5) {
            rankText = "Top 5! (${game.currentRunRank}${_getOrdinal(game.currentRunRank!)} Place)";
            rankColor = Colors.blue[700]!;
        } else {
            rankText = "Good Job!";
        }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
           BoxShadow(color: Colors.black12, blurRadius: 16, offset: const Offset(0, 8))
        ]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
            Text("LEVEL SOLVED", style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 16),
            Text(
                "\"$_cachedQuote\"",
                textAlign: TextAlign.center,
                style: GoogleFonts.kanit(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    const Icon(Icons.timer, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(timeText, style: GoogleFonts.robotoMono(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
            ),
            const SizedBox(height: 8),
            Text(rankText, style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: rankColor)),
            const SizedBox(height: 32),
            
            // Next Level Arrow Button
            GestureDetector(
                onTap: () {
                    _cachedQuote = null; // Clear
                    game.nextLevel();
                },
                child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                            BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                            )
                        ]
                    ),
                    child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 40),
                ),
            ),
        ],
      ),
    );
  }

  String _getOrdinal(int i) {
    if (i >= 11 && i <= 13) return "th";
    switch (i % 10) {
      case 1: return "st";
      case 2: return "nd";
      case 3: return "rd";
      default: return "th";
    }
  }
}

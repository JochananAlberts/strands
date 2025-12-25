import 'package:flutter/material.dart';
import 'level_data.dart';
import 'grid_generator.dart';
import 'services/dictionary_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameModel extends ChangeNotifier {
  // 6 columns x 8 rows = 48 letters
  final int columns = 6;
  final int rows = 8;
  
  late List<String> grid;
  late String theme;
  late String spangram; // The spanning word(s)
  late Map<String, List<int>> solutions; // Word -> List of grid indices
  
  // State
  Set<int> selectedIndices = {};
  Set<int> foundIndices = {};
  List<String> foundWords = [];
  List<int> lastFoundWordIndices = []; // For animation
  bool isGameWon = false;
  
  int currentLevelIndex = 0;
  bool isLoading = true;

  int accumulatedTimeSeconds = 0; // Total persisted time
  int? _sessionStartTimeMillis; // Start of current active session (null if paused)

  GameModel() {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    int savedLevel = prefs.getInt('currentLevelIndex') ?? 0;
    
    // Load the level locally first
    await loadLevel(savedLevel);
    
    // Restore state if valid
    List<String>? savedFoundWords = prefs.getStringList('foundWords_level_$savedLevel');
    List<String>? savedBonusWords = prefs.getStringList('bonusWords_level_$savedLevel');
    
    // Restore timer
    accumulatedTimeSeconds = prefs.getInt('accumulatedTime_level_$savedLevel') ?? 0;
    // We do NOT automatically start the timer here. The UI (GameScreen) must trigger startTimer().

    if (savedFoundWords != null) {
      for (String word in savedFoundWords) {
        if (solutions.containsKey(word)) {
          foundWords.add(word);
          foundIndices.addAll(solutions[word]!);
        }
      }
    }
    
    if (savedBonusWords != null) {
      foundBonusWords.addAll(savedBonusWords);
    }
    
    // Restore hint usage
    hintsUsed = prefs.getInt('hintsUsed_level_$savedLevel') ?? 0;
    bonusWordsUsedForHints = prefs.getInt('bonusWordsUsed_level_$savedLevel') ?? 0;
    
    // Check win condition after restore
    if (foundWords.length == solutions.length) {
      isGameWon = true;
    }
    
    notifyListeners();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentLevelIndex', currentLevelIndex);
    await prefs.setStringList('foundWords_level_$currentLevelIndex', foundWords);
    await prefs.setStringList('bonusWords_level_$currentLevelIndex', foundBonusWords.toList());
    await prefs.setInt('hintsUsed_level_$currentLevelIndex', hintsUsed);
    await prefs.setInt('bonusWordsUsed_level_$currentLevelIndex', bonusWordsUsedForHints);
    // Save timer
    // If running, we must checkpoint the current session into the accumulated time temporarily for saving?
    // Or, we just save accumulatedTimeSeconds.
    // If we crash, we lose the current session's seconds. That's acceptable.
    // Better: if running, add current session to accumulated, save, then reset session start to now.
    
    int currentTotal = accumulatedTimeSeconds;
    if (_sessionStartTimeMillis != null) {
      currentTotal += (DateTime.now().millisecondsSinceEpoch - _sessionStartTimeMillis!) ~/ 1000;
    }
    await prefs.setInt('accumulatedTime_level_$currentLevelIndex', currentTotal);
  }
  
  // Leaderboard State
  List<int> currentTopScores = [];
  int? currentRunRank; // 1-based rank of the current run, or null

  Future<List<int>> getTopScores(int levelIndex) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? scores = prefs.getStringList('leaderboard_level_$levelIndex');
    if (scores == null) return [];
    return scores.map((s) => int.tryParse(s) ?? 0).toList();
  }
  
  Future<int?> getHighScore(int levelIndex) async {
    List<int> scores = await getTopScores(levelIndex);
    if (scores.isEmpty) return null;
    return scores.first; // Best time is first because we sort ASC
  }
  
  Future<void> _checkAndSaveHighScore() async {
    if (!isGameWon) return;
    
    final prefs = await SharedPreferences.getInstance();
    int currentRunTime = totalSecondsPlayed;
    
    // Load existing leaderboard
    List<int> scores = await getTopScores(currentLevelIndex);
    
    // Add new score
    scores.add(currentRunTime);
    
    // Sort (ASC because lower time is better)
    scores.sort();
    
    // Keep top 5
    if (scores.length > 5) {
      scores = scores.sublist(0, 5);
    }
    
    // Determine rank
    // Note: If multiple identical times exists, this finds the first one. 
    // Since we just added it and sorted, if it's unique it's there. 
    // If it's duplicate, it shares the rank.
    int rank = scores.indexOf(currentRunTime) + 1;
    if (rank == 0) rank = -1; // Should not happen if we just added it, unless it was dropped ( > top 5)
    
    // If it was dropped (not in top 5), rank is > 5 or conceptually "unranked" in this context
    if (!scores.contains(currentRunTime)) {
       currentRunRank = null; 
    } else {
       currentRunRank = rank;
    }
    
    currentTopScores = scores;
    
    await prefs.setStringList(
        'leaderboard_level_$currentLevelIndex', 
        scores.map((e) => e.toString()).toList()
    );
    
    // Legacy support: also update 'highScore' for the menu checks if we want to keep using that
    if (rank == 1) {
       await prefs.setInt('highScore_level_$currentLevelIndex', currentRunTime);
    }
    
    debugPrint("Leaderboard updated. Rank: $currentRunRank. Top: $scores");
    notifyListeners();
  }
  
  // Timer controls called by UI
  void startTimer() {
    if (isGameWon) return;
    if (_sessionStartTimeMillis == null) {
      _sessionStartTimeMillis = DateTime.now().millisecondsSinceEpoch;
      notifyListeners(); // Optional
    }
  }
  
  void stopTimer() {
    if (_sessionStartTimeMillis != null) {
      int sessionDuration = DateTime.now().millisecondsSinceEpoch - _sessionStartTimeMillis!;
      accumulatedTimeSeconds += sessionDuration ~/ 1000;
      _sessionStartTimeMillis = null;
      _saveProgress(); // Persist
      notifyListeners();
    }
  }
  
  int get totalSecondsPlayed {
    int total = accumulatedTimeSeconds;
    if (_sessionStartTimeMillis != null) {
      total += (DateTime.now().millisecondsSinceEpoch - _sessionStartTimeMillis!) ~/ 1000;
    }
    return total;
  }

  bool get isTimerRunning => _sessionStartTimeMillis != null;
  
  Future<void> resetLevel() async {
    final prefs = await SharedPreferences.getInstance();
    // Clear save for this level
    await prefs.remove('foundWords_level_$currentLevelIndex');
    await prefs.remove('bonusWords_level_$currentLevelIndex');
    await prefs.remove('hintsUsed_level_$currentLevelIndex');
    await prefs.remove('bonusWordsUsed_level_$currentLevelIndex');
    await prefs.remove('accumulatedTime_level_$currentLevelIndex');
    
    // Reload
    loadLevel(currentLevelIndex);
  }

  Future<void> loadLevel(int index) async {
    if (index >= LevelData.levels.length) index = 0; // Loop back
    currentLevelIndex = index;
    
    isLoading = true;
    notifyListeners();
    
    Level level = LevelData.levels[index];
    theme = level.theme;
    spangram = level.spangram;
    foundWords.clear();
    foundIndices.clear();
    // foundWords.clear(); // Removed duplicate
    foundIndices.clear();
    selectedIndices.clear();
    foundBonusWords.clear();
    hintsUsed = 0;
    bonusWordsUsedForHints = 0;
    isGameWon = false;
    
    // Reset timer for new level
    accumulatedTimeSeconds = 0;
    _sessionStartTimeMillis = null; // Do not start automatically until UI says so
    
    // Generate Grid
    final generator = GridGenerator();
    var result = await generator.generate(level);
    
    if (result != null) {
      grid = result.$1;
      solutions = result.$2;
    } else {
      // Fallback if generation fails (shouldn't with good data)
      // Create a dummy grid
      grid = List.filled(columns * rows, '?');
      solutions = {};
      print("Generation failed for level $index");
    }
    
    isLoading = false;
    // Note: We don't save here immediately to avoid overwriting legitimate progress if called during restore
    // _saveProgress() is called on state changes
    // BUT we should save the new start time if it's truly a new level load (not a restore).
    // _loadProgress logic handles the restore case by overwriting this if a saved time exists.
    // However, _loadProgress calls loadLevel first.
    // So loadLevel sets it to NOW. Then _loadProgress overwrites it with SAVED. Correct.
    notifyListeners();
  }
  
  Future<void> nextLevel() async {
    await loadLevel(currentLevelIndex + 1);
    await _saveProgress(); // Persist the move to the new level
  }

  // User Interaction
  void startDrag(int index) {
    if (foundIndices.contains(index)) return; // Already found
    selectedIndices.clear();
    selectedIndices.add(index);
    notifyListeners();
  }

  void updateDrag(int index) {
    if (foundIndices.contains(index)) return;
    // Backtracking logic
    if (selectedIndices.contains(index)) {
      // If we are dragging back over the previous letter, remove the last one
      if (selectedIndices.length > 1) {
        final last = selectedIndices.last;
        final secondLast = selectedIndices.elementAt(selectedIndices.length - 2);
        
        if (index == secondLast) {
          selectedIndices.remove(last);
          notifyListeners();
          return;
        }
      }
      // If dragging over an arbitrary already-selected node, maybe ignore or truncate. 
      // Standard Strands behavior is usually to just do nothing unless it's immediate backtrack.
      return; 
    }
    
    // Check neighbor match
    int lastIndex = selectedIndices.last;
    if (_isNeighbor(lastIndex, index)) {
      selectedIndices.add(index);
      notifyListeners();
    }
  }

  // Hint state
  String? hintedWord;
  List<int>? hintedIndices; // Store indices for rendering glow
  
  Set<String> foundBonusWords = {}; // Already found non-theme words
  int hintsUsed = 0; // Usage count
  int bonusWordsUsedForHints = 0; // How many words have been "spent"

  // Helper for UI
  String get currentWordBeingFormed {
    if (selectedIndices.isEmpty) return "";
    String word = selectedIndices.map((i) => grid[i]).join();
    if (word.length > 16) {
      return word.substring(0, 16);
    }
    return word;
  }

  int get wordsRequiredForHint {
    if (hintsUsed == 0) return 3;
    if (hintsUsed == 1) return 4;
    return 5;
  }
  
  int get currentProgress => foundBonusWords.length - bonusWordsUsedForHints;

  double get hintProgress => (currentProgress / wordsRequiredForHint).clamp(0.0, 1.0);
  bool get isHintActive => currentProgress >= wordsRequiredForHint;
  bool get canUseHint => isHintActive && hintedWord == null;

  void solveAll() {
    for (String word in solutions.keys) {
      if (!foundWords.contains(word)) {
        foundWords.add(word);
        foundIndices.addAll(solutions[word]!);
      }
    }
    // Handle spangram logic if needed (usually ensuring it's in foundWords is enough)
    
    isGameWon = true;
    hintedWord = null;
    hintedIndices = null;
    
    _saveProgress();
    notifyListeners();
  }

  void consumeHint({bool force = false}) {
    // If forced (e.g. shake), we bypass the progress check.
    // If not forced, we respect the rules.
    if (!force && !canUseHint) return;
    
    // Don't override existing hint
    if (hintedWord != null) return;
    
    // Find a word that hasn't been found yet
    String? target;
    List<String> unfoundWords = solutions.keys.where((w) => !foundWords.contains(w)).toList();
    
    if (unfoundWords.isNotEmpty) {
      // Prioritize theme words over Spangram
      // Only show Spangram if it's the ONLY thing left (or if only spangrams are left, edge case)
      List<String> themeWords = unfoundWords.where((w) => w != spangram).toList();
      
      if (themeWords.isNotEmpty) {
        // Pick a theme word (first one available)
        target = themeWords.first;
      } else {
        // Only spangram left
        target = spangram;
      }
    }
    
    if (target != null) {
      hintedWord = target;
      hintedIndices = solutions[target];
      
      // Deduct cost ONLY if it was a "paid" hint
      if (!force) {
        bonusWordsUsedForHints += wordsRequiredForHint;
        hintsUsed++;
      }
      
      _saveProgress(); // Save
      notifyListeners();
      debugPrint("Hint activated for: $target (Forced: $force)");
    }
  }

  Future<void> endDrag() async {
    // Check word
    String formedWord = selectedIndices.map((i) => grid[i]).join();
    
    // Check if it's a solution
    if (solutions.containsKey(formedWord)) {
      // Validate indices match
       List<int> expectedIndices = solutions[formedWord]!;
       
       // Strict comparison
       if (_areListsEqual(selectedIndices.toList(), expectedIndices)) {
         foundWords.add(formedWord);
         foundIndices.addAll(selectedIndices);
         lastFoundWordIndices = List.from(selectedIndices); // Capture for animation
         
         // Clear hint if found
         if (formedWord == hintedWord) {
           hintedWord = null;
           hintedIndices = null;
         }
         
         if (formedWord == spangram) {
           // Special spangram effect
         }
         
         // Check win
         if (foundWords.length == solutions.length) {
           isGameWon = true;
           _checkAndSaveHighScore();
         }
         _saveProgress(); // Save
       }
    } else {
      // Check compatible words in dictionary
      final isValid = await DictionaryService().isWordValid(formedWord);
      
      if (isValid && formedWord.length >= 4) {
        // Only count if unique
        if (!foundBonusWords.contains(formedWord)) {
           debugPrint("Valid UNIQUE bonus word found: $formedWord.");
           foundBonusWords.add(formedWord);
           _saveProgress(); // Save
           // Progress is automatic via getter
        } else {
           debugPrint("Word already found: $formedWord");
        }
      } else {
        if (!isValid) debugPrint("Invalid word: $formedWord");
      }
    }
    
    selectedIndices.clear();
    notifyListeners();
  }
  
  bool _areListsEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _isNeighbor(int i1, int i2) {
    int r1 = i1 ~/ columns;
    int c1 = i1 % columns;
    int r2 = i2 ~/ columns;
    int c2 = i2 % columns;
    
    return (r1 - r2).abs() <= 1 && (c1 - c2).abs() <= 1;
  }
}

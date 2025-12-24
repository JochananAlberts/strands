import 'package:flutter/material.dart';
import 'level_data.dart';
import 'grid_generator.dart';

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
  bool isGameWon = false;
  
  // Hint system
  int hintsAvailable = 0; // Starts at 0, gain 1 for every 3 non-theme words (omitted for MVP, or simplified)
  
  int currentLevelIndex = 0;
  bool isLoading = true;

  GameModel() {
    _initFirstLevel();
  }

  Future<void> _initFirstLevel() async {
    await loadLevel(0);
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
    selectedIndices.clear();
    isGameWon = false;
    
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
    notifyListeners();
  }
  
  void nextLevel() {
    loadLevel(currentLevelIndex + 1);
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

  void endDrag() {
    // Check word
    String formedWord = selectedIndices.map((i) => grid[i]).join();
    
    // Check if it's a solution
    if (solutions.containsKey(formedWord)) {
      // Validate indices match (handle duplicate words if any, though strands usu unique usage)
      // For now assume unique usage in grid for simplicity or strict checking against solution value
       List<int> expectedIndices = solutions[formedWord]!;
       
       // Set comparison (order doesn't strict matter for 'found', but path matters for forming)
       // Strands allows path winding.
       // If the set of indices matches, it's good.
       if (_areSetsEqual(selectedIndices, expectedIndices.toSet())) {
         foundWords.add(formedWord);
         foundIndices.addAll(selectedIndices);
         
         if (formedWord == spangram) {
           // Special spangram effect
         }
         
         // Check win
         if (foundWords.length == solutions.length) {
           isGameWon = true;
         }
       }
    }
    
    selectedIndices.clear();
    notifyListeners();
  }
  
  bool _areSetsEqual(Set<int> a, Set<int> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  bool _isNeighbor(int i1, int i2) {
    int r1 = i1 ~/ columns;
    int c1 = i1 % columns;
    int r2 = i2 ~/ columns;
    int c2 = i2 % columns;
    
    return (r1 - r2).abs() <= 1 && (c1 - c2).abs() <= 1;
  }
}

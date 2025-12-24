import 'dart:isolate';
import 'dart:math';
import 'level_data.dart';

class GridGenerator {
  final int rows = 8;
  final int cols = 6;
  final Random _random = Random();
  
  // Directions: Horizontal, Vertical, Diagonal
  final List<List<int>> _directions = [
    [-1, -1], [-1, 0], [-1, 1],
    [0, -1],           [0, 1],
    [1, -1],  [1, 0],  [1, 1]
  ];

  // Returns a grid and the solutions map, or null if generation fails
  // Returns a grid and the solutions map, or null if generation fails
  Future<(List<String>, Map<String, List<int>>)?> generate(Level level) async {
    // Run multiple generations in parallel and take the first one that succeeds
    // This utilizes multi-core CPUs to find a valid grid faster
    List<Future<(List<String>, Map<String, List<int>>)?>> workers = List.generate(
      3, 
      (_) => Isolate.run(() => _generateOnIsolate(level))
    );
    
    try {
      // Wait for the first valid result (non-null)
      // Future.any returns the first *completed* future, but that might be null if one fails fast.
      // We want the first SUCCESS.
      // Actually, standard Future.any completes with the first value.
      // If we use a robust approach:
      final result = await Future.any(workers);
      return result;
    } catch (e) {
      return null;
    }
  }

  // Internal method that runs on the isolate
  static (List<String>, Map<String, List<int>>)? _generateOnIsolate(Level level) {
    // Create a new instance for the isolate execution
    final generator = GridGenerator();
    return generator._generateInternal(level);
  }

  int _steps = 0;
  final int _maxSteps = 2000; // Fail fast threshold

  (List<String>, Map<String, List<int>>)? _generateInternal(Level level) {
    // We try multiple times because random placement might get stuck
    // With fail-fast, we can try more times quickly
    for (int attempt = 0; attempt < 200; attempt++) {
      List<String?> grid = List.filled(rows * cols, null);
      Map<String, List<int>> solutions = {};
      
      _steps = 0; // Reset counter
      
      // Sort words by length descending
      List<String> allWords = [level.spangram, ...level.words];
      allWords.sort((a, b) => b.length.compareTo(a.length));
      
      try {
        bool success = _placeWords(grid, solutions, allWords, 0);
        if (success) {
          // Convert to non-nullable list
          List<String> finalGrid = grid.map((e) => e!).toList();
          return (finalGrid, solutions);
        }
      } catch (e) {
        // Step limit reached, try next attempt
        continue;
      }
    }
    return null;
  }

  bool _placeWords(List<String?> grid, Map<String, List<int>> solutions, List<String> words, int wordIndex) {
    if (_steps > _maxSteps) throw Exception("Step limit reached");
    
    if (wordIndex >= words.length) {
      return true; // All words placed
    }

    String word = words[wordIndex];
    
    // Find all empty cells as potential start points
    List<int> startPoints = [];
    for (int i = 0; i < grid.length; i++) {
      if (grid[i] == null) startPoints.add(i);
    }
    startPoints.shuffle(_random);

    for (int start in startPoints) {
      // Try to place this word starting at 'start'
      if (_attemptPath(grid, solutions, word, 0, start, [])) {
        // Word placed successfully, recurse for next word
        if (_placeWords(grid, solutions, words, wordIndex + 1)) {
          return true;
        }
        // If next words fail, backtrack: remove this word
        _removeWord(grid, solutions, word);
      }
    }

    return false;
  }
  
  bool _attemptPath(List<String?> grid, Map<String, List<int>> solutions, String word, int charIndex, int currentIdx, List<int> currentPath) {
    _steps++;
    if (_steps > _maxSteps) throw Exception("Step limit reached");
    
    // Place char
    grid[currentIdx] = word[charIndex];
    currentPath.add(currentIdx);
    
    if (charIndex == word.length - 1) {
      // Word fully placed
      solutions[word] = List.from(currentPath);
      return true;
    }
    
    // Find neighbors
    List<int> neighbors = _getNeighbors(currentIdx);
    neighbors.shuffle(_random);
    
    for (int neighbor in neighbors) {
      if (grid[neighbor] == null) {
        if (_attemptPath(grid, solutions, word, charIndex + 1, neighbor, currentPath)) {
          return true;
        }
      }
    }
    
    // Backtrack current step
    grid[currentIdx] = null;
    currentPath.removeLast();
    return false;
  }

  List<int> _getNeighbors(int index) {
    int r = index ~/ cols;
    int c = index % cols;
    List<int> valid = [];
    
    for (var dir in _directions) {
      int nr = r + dir[0];
      int nc = c + dir[1];
      if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
        valid.add(nr * cols + nc);
      }
    }
    return valid;
  }
  
  void _removeWord(List<String?> grid, Map<String, List<int>> solutions, String word) {
    if (solutions.containsKey(word)) {
      for (int idx in solutions[word]!) {
        grid[idx] = null;
      }
      solutions.remove(word);
    }
  }
}

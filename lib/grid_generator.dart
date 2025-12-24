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
  Future<(List<String>, Map<String, List<int>>)?> generate(Level level) async {
    // We try multiple times because random placement might get stuck
    for (int attempt = 0; attempt < 50; attempt++) {
      List<String?> grid = List.filled(rows * cols, null);
      Map<String, List<int>> solutions = {};
      
      // Sort words by length descending (usually helps packing)
      // Including spangram in the list of words to place
      List<String> allWords = [level.spangram, ...level.words];
      // Sort: longest first
      allWords.sort((a, b) => b.length.compareTo(a.length));
      
      bool success = _placeWords(grid, solutions, allWords, 0);
      
      if (success) {
        // Convert to non-nullable list
        List<String> finalGrid = grid.map((e) => e!).toList();
        return (finalGrid, solutions);
      }
    }
    return null;
  }

  bool _placeWords(List<String?> grid, Map<String, List<int>> solutions, List<String> words, int wordIndex) {
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
      // We need to find a path of length word.length
      // This is another DFS
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

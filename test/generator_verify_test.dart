import 'package:flutter_test/flutter_test.dart';
import 'package:gamen/grid_generator.dart';
import 'package:gamen/level_data.dart';

void main() {
  test('Generator handles new Level 1 (Long Spangram)', () async {
    final generator = GridGenerator();
    final level = LevelData.levels[0]; // Healthy Snack (FRUITSALAD)
    
    // Attempt generation (retry count might be needed if heuristic based, but strands gen is usually backtracking)
    final result = await generator.generate(level);
    
    expect(result, isNotNull, reason: "Failed to generate Level 1");
    if (result != null) {
      print("Level 1 Generated Successfully:");
      _printGrid(result.$1, 6);
    }
  });

  test('Generator handles Level 3 (JUNGLEANIMALS - 13 chars)', () async {
    final generator = GridGenerator();
    final level = LevelData.levels[2]; 
    
    final result = await generator.generate(level);
     expect(result, isNotNull, reason: "Failed to generate Level 3");
  });
}

void _printGrid(List<String> grid, int cols) {
  for (int i = 0; i < grid.length; i += cols) {
    print(grid.sublist(i, i + cols).join(' '));
  }
}

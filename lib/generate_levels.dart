import 'dart:convert';
import 'level_data.dart';
import 'grid_generator.dart';

Future<void> main() async {
  print("Generating levels...");
  final generator = GridGenerator();

  for (int i = 0; i < LevelData.levels.length; i++) {
    var level = LevelData.levels[i];
    print("\n// Generating Level ${i + 1}: ${level.theme}");
    
    var result = await generator.generate(level);
    if (result != null) {
      var grid = result.$1;
      var solutions = result.$2;
      
      print("Level(");
      print("  theme: \"${level.theme}\",");
      print("  spangram: \"${level.spangram}\",");
      print("  words: ${jsonEncode(level.words)},");
      print("  grid: ${jsonEncode(grid)},");
      // Manually format solutions to standard Dart map syntax
      print("  solutions: {");
      solutions.forEach((k, v) {
        print("    \"$k\": ${jsonEncode(v)},");
      });
      print("  },");
      print("),");
    } else {
      print("// FAILED to generate Level ${i + 1}");
    }
  }
}

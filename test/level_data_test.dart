import 'package:flutter_test/flutter_test.dart';
import 'package:gamen/level_data.dart'; // Adjust import based on package name

void main() {
  test('All levels must have exactly 48 characters', () {
    for (int i = 0; i < LevelData.levels.length; i++) {
      final level = LevelData.levels[i];
      int spangramLength = level.spangram.length;
      int wordsLength = level.words.fold(0, (sum, word) => sum + word.length);
      int total = spangramLength + wordsLength;

      expect(total, 48, 
        reason: 'Level $i ("${level.theme}") has $total characters instead of 48.\n'
        'Spangram: ${level.spangram} ($spangramLength)\n'
        'Words: ${level.words} ($wordsLength)'
      );
    }
  });

  test('All levels must have a theme, spangram, and words', () {
    for (final level in LevelData.levels) {
       expect(level.theme, isNotEmpty);
       expect(level.spangram, isNotEmpty);
       expect(level.words, isNotEmpty);
    }
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:gamen/game_model.dart';
import 'package:gamen/services/dictionary_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUp(() async {
    // Mock path provider
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return '.';
      },
    );
    
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    final db = await DictionaryService().database;
    await db.delete('words');
    await db.insert('words', {'word': 'TEST'}); // 4 letters
    await db.insert('words', {'word': 'VALID'}); // 5 letters
    await db.insert('words', {'word': 'LONGWORD'}); // 8 letters
  });

  group('GameModel Hint System', () {
    test('Hint progress lifecycle with scaling costs', () async {
      final game = GameModel();
      // Setup
      game.grid = List.filled(48, 'A');
      game.solutions = {'HIDDEN': [0, 1]}; 
      game.hintedWord = null;
      // Reset state for test isolation (though new instance should be clean)
      game.foundBonusWords = {};
      game.hintsUsed = 0;
      game.bonusWordsUsedForHints = 0;
      
      // Initial state: 0 found, 3 required
      expect(game.wordsRequiredForHint, 3);
      expect(game.isHintActive, false);
      expect(game.currentProgress, 0);

      // 1. Find 1st valid word: TEST
      // Mock grid for TEST
      game.grid[0]='T'; game.grid[1]='E'; game.grid[2]='S'; game.grid[3]='T';
      game.selectedIndices = {0,1,2,3};
      await game.endDrag();
      
      expect(game.foundBonusWords.length, 1);
      expect(game.currentProgress, 1);
      expect(game.isHintActive, false);

      // 2. Find 2nd valid word: VALID
      // Mock grid for VALID
      game.grid[0]='V'; game.grid[1]='A'; game.grid[2]='L'; game.grid[3]='I'; game.grid[4]='D';
      game.selectedIndices = {0,1,2,3,4};
      await game.endDrag();
      
      expect(game.foundBonusWords.length, 2);
      expect(game.currentProgress, 2);
      
      // 3. Find 3rd valid word: LONGWORD
      // Mock grid
      game.grid = 'LONGWORD'.split('') + List.filled(40, 'X');
      game.selectedIndices = {0,1,2,3,4,5,6,7};
      await game.endDrag();
      
      expect(game.foundBonusWords.length, 3);
      expect(game.currentProgress, 3);
      
      // Hint should be active (3 >= 3)
      expect(game.isHintActive, true);
      
      // 4. Consume Hint
      game.consumeHint();
      
      // State check after consumption
      expect(game.hintedWord, 'HIDDEN');
      expect(game.hintsUsed, 1);
      expect(game.bonusWordsUsedForHints, 3);
      expect(game.currentProgress, 0); // 3 found - 3 used = 0
      expect(game.isHintActive, false);
      
      // 5. Verify next cost is 4
      expect(game.wordsRequiredForHint, 4);
    });
  });
}

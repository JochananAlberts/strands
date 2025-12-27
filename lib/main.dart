import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'intro_screen.dart';
import 'game_model.dart';
import 'services/dictionary_service.dart';
import 'app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize dictionary service
  await DictionaryService().loadDictionary();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameModel()..loadAllHighScores(),
      child: MaterialApp(
        title: "Lisa's Games",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.primary),
        ),
        home: const IntroScreen(),
      ),
    );
  }
}

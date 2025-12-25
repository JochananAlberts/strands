# Lisa's Game (Strands Clone)

A polished word-finding puzzle game inspired by NYT Strands, built with Flutter.

## Features

- **Dynamic Word Search**: Find theme words and the spanning "Spangram" to solve the level.
- **Hint System**: 
  - Finds valid dictionary words (local ~370k word SQLite database) to charge the hint bar.
  - Spend hints to reveal letters of unfound words with a glowing visual effect.
- **Visual Polish**: 
  - Clean "Lisa's Game" branding.
  - Smooth animations, rounded tile visuals for the intro.
  - Dynamic "Current Word" preview in the header.
- **Cheat Mode**: 
  - Hidden developer tools for testing (5 taps on lightbulb to solve).
- **Levels**: 
  - 10 custom levels with multi-word spangrams.

## Tech Stack

- **Framework**: Flutter
- **Database**: `sqflite` with `words_alpha.txt` asset.
- **State Management**: `Provider`.
- **Fonts**: `GoogleFonts` (Kanit).

## Getting Started

1.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
2.  **Run the app**:
    ```bash
    flutter run
    ```
    *Note: The first launch performs a one-time dictionary import which may take a few seconds.*

## Development

- **Tests**: Run `flutter test` to verify game logic and dictionary services.
- **Assets**: Ensure `assets/dictionary.txt` is present.

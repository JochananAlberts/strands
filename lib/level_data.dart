class Level {
  final String theme;
  final String spangram;
  final List<String> words;

  const Level({
    required this.theme,
    required this.spangram,
    required this.words,
  });
}

class LevelData {
  static const List<Level> levels = [
    // Level 1: Healthy Snack (48 chars)
    // Spangram: FRUIT SALAD (10)
    // Words: APPLE(5), GRAPE(5), MANGO(5), MELON(5), BERRY(5), PEACH(5), PEAR(4), PLUM(4)
    // Sum: 10 + 25 + 5 + 4 + 4 = 48
    Level(
      theme: "Healthy Snack",
      spangram: "FRUITSALAD",
      words: ["APPLE", "GRAPE", "MANGO", "MELON", "BERRY", "PEACH", "PEAR", "PLUM"],
    ),
    
    // Level 2: Color Palette (48 chars)
    // Spangram: MIXING COLORS (12)
    // Words: VIOLET(6), INDIGO(6), ORANGE(6), YELLOW(6), GREEN(5), TEAL(4), RED(3)
    // Sum: 12 + 24 + 5 + 4 + 3 = 48
    Level(
      theme: "Color Palette",
      spangram: "MIXINGCOLORS",
      words: ["VIOLET", "INDIGO", "ORANGE", "YELLOW", "GREEN", "TEAL", "RED"],
    ),

    // Level 3: Wild Side (48 chars)
    // Spangram: JUNGLE ANIMALS (13)
    // Words: TIGER(5), ZEBRA(5), PANDA(5), HIPPO(5), RHINO(5), COBRA(5), OTTER(5)
    // Sum: 13 + 35 = 48
    Level(
      theme: "Wild Side",
      spangram: "JUNGLEANIMALS",
      words: ["TIGER", "ZEBRA", "PANDA", "HIPPO", "RHINO", "COBRA", "OTTER"],
    ),

    // Level 4: Game On (48 chars)
    // Spangram: TEAM SPORTS (10)
    // Words: SOCCER(6), HOCKEY(6), TENNIS(6), FOOTBALL(8), RUGBY(5), CRICKET(7)
    // Sum: 10 + 18 + 8 + 5 + 7 = 48
    Level(
      theme: "Game On",
      spangram: "TEAMSPORTS",
      words: ["SOCCER", "HOCKEY", "TENNIS", "FOOTBALL", "RUGBY", "CRICKET"],
    ),

    // Level 5: Forecast (48 chars)
    // Spangram: STORMY WEATHER (13)
    // Words: THUNDER(7), LIGHTNING(9), RAINY(5), WINDY(5), CLOUD(5), SNOW(4)
    // Sum: 13 + 7 + 9 + 5 + 5 + 5 + 4 = 48
    Level(
      theme: "Forecast",
      spangram: "STORMYWEATHER",
      words: ["THUNDER", "LIGHTNING", "RAINY", "WINDY", "CLOUD", "SNOW"],
    ),
    
    // Level 6: Interior Design (48 chars)
    // Spangram: LIVING ROOM (10)
    // Words: COUCH(5), CHAIR(5), TABLE(5), SHELF(5), LAMP(4), RUG(3), CURTAIN(7), VASE(4)
    // Sum: 10 + 20 + 4 + 3 + 7 + 4 = 48
    Level(
      theme: "Interior Design",
      spangram: "LIVINGROOM",
      words: ["COUCH", "CHAIR", "TABLE", "SHELF", "LAMP", "RUG", "CURTAIN", "VASE"],
    ),

    // Level 7: Space (48 chars)
    // Spangram: OUTER SPACE (10)
    // Words: JUPITER(7), SATURN(6), URANUS(6), NEPTUNE(7), MARS(4), VENUS(5), SUN(3)
    // Sum: 10 + 7 + 6 + 6 + 7 + 4 + 5 + 3 = 48
    Level(
      theme: "Space",
      spangram: "OUTERSPACE",
      words: ["JUPITER", "SATURN", "URANUS", "NEPTUNE", "MARS", "VENUS", "SUN"],
    ),
    
    // Level 8: Education (48 chars)
    // Spangram: SCHOOL SUBJECTS (14)
    // Words: MATH(4), SCIENCE(7), HISTORY(7), ENGLISH(7), ARTS(4), MUSIC(5)
    // Sum: 14 + 4 + 7 + 7 + 7 + 4 + 5 = 48
    Level(
      theme: "Education",
      spangram: "SCHOOLSUBJECTS",
      words: ["MATH", "SCIENCE", "HISTORY", "ENGLISH", "ARTS", "MUSIC"],
    ),

    // Level 9: Yummy (48 chars)
    // Spangram: FAST FOOD CHAIN (13)
    // Words: BURGER(6), FRIES(5), PIZZA(5), SHAKE(5), TACO(4), SODA(4), NUGGET(6)
    // Sum: 13 + 6 + 15 + 8 + 6 = 48
    Level(
      theme: "Yummy",
      spangram: "FASTFOODCHAIN",
      words: ["BURGER", "FRIES", "PIZZA", "SHAKE", "TACO", "SODA", "NUGGET"],
    ),
    
    // Level 10: Hardware (48 chars)
    // Spangram: COMPUTER PARTS (13)
    // Words: KEYBOARD(8), MONITOR(7), MOUSE(5), SCREEN(6), LAPTOP(6), CPU(3)
    // Sum: 13 + 8 + 7 + 5 + 6 + 6 + 3 = 48
    Level(
      theme: "Hardware",
      spangram: "COMPUTERPARTS",
      words: ["KEYBOARD", "MONITOR", "MOUSE", "SCREEN", "LAPTOP", "CPU"],
    ),
  ];
}

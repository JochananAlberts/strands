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
    // Level 1: Fruit Salad (48 chars)
    // Spangram: FRUITS (6)
    // APPLE(5), PEACH(5), GRAPE(5), LEMON(5), MELON(5), MANGO(5), PLUM(4), PEAR(4), LIME(4)
    // Sum: 6 + 30 + 12 = 48
    Level(
      theme: "Fruit Salad",
      spangram: "FRUITS",
      words: ["APPLE", "PEACH", "GRAPE", "LEMON", "MELON", "MANGO", "PLUM", "PEAR", "LIME"],
    ),
    
    // Level 2: Colors of the Rainbow (48 chars)
    // Spangram: SPECTRUM (8)
    // VIOLET(6), INDIGO(6), ORANGE(6), YELLOW(6), GREEN(5), BLUE(4), RED(3), CYAN(4) 
    // Wait, 3 letter words allow? Strands usually 4+. 
    // Let's adjust.
    // SPECTRUM(8)
    // VIOLET(6), ORANGE(6), YELLOW(6) -> 18
    // INDIGO(6) -> 6
    // GREEN(5) -> 5
    // BLUE(4) -> 4
    // TEAL(4) -> 4
    // PINK(5) -> 5? No
    // Total so far: 8+18+6+5+4+4 = 45. Need 3. RED.
    // Okay, allow 3 letter words for now or find specific combo.
    Level(
      theme: "Colorful",
      spangram: "SPECTRUM",
      words: ["VIOLET", "ORANGE", "YELLOW", "INDIGO", "GREEN", "BLUE", "TEAL", "RED"],
    ),

    // Level 3: Zoo Animals (48 chars)
    // Spangram: ANIMALS (7)
    // TIGER(5), ZEBRA(5), PANDA(5), KOALA(5), CAMEL(5) -> 25
    // LION(4), BEAR(4), WOLF(4), DEER(4) -> 16
    // Total: 7 + 25 + 16 = 48.
    Level(
      theme: "Zoo Trip",
      spangram: "ANIMALS",
      words: ["TIGER", "ZEBRA", "PANDA", "KOALA", "CAMEL", "LION", "BEAR", "WOLF", "DEER"],
    ),

    // Level 4: Sports (48 chars)
    // Spangram: ATHLETE (7)
    // SOCCER(6), TENNIS(6), HOCKEY(6) -> 18
    // RUGBY(5) -> 5
    // GOLF(4), SWIM(4), POLO(4) -> 12
    // Sum: 7 + 18 + 5 + 12 = 42. Need 6.
    // KARATE(6).
    Level(
      theme: "Let's Play",
      spangram: "ATHLETE",
      words: ["SOCCER", "TENNIS", "HOCKEY", "RUGBY", "KARATE", "GOLF", "SWIM", "POLO"],
    ),

    // Level 5: Weather (48 chars)
    // Spangram: FORECAST (8)
    // CLOUDY(6), STORMY(6), BREEZY(6) -> 18
    // RAIN(4), SNOW(4), HAIL(4), WIND(4) -> 16
    // Sum: 8 + 18 + 16 = 42. Need 6.
    // SUNNY(5)? No need 6.
    // ICY(3)? No.
    // Let's do SUMMER(6).
    Level(
      theme: "Look Outside",
      spangram: "FORECAST",
      words: ["CLOUDY", "STORMY", "BREEZY", "SUMMER", "RAIN", "SNOW", "HAIL", "WIND"],
    ),
    
    // Level 6: Furniture (48 chars)
    // Spangram: BEDROOM (7)
    // DRESSER(7) -> 7
    // PILLOW(6), MIRROR(6) -> 12
    // LAMP(4), RUG(3), BED(3) ... too small.
    // Let's resize.
    // BEDROOM (7)
    // DRESSER (7)
    // CLOSET (6)
    // PILLOW (6)
    // CARPET (6)
    // LAMP (4)
    // DESK (4)
    // SOFA (4)
    // CHAIR (5)?
    // Sum: 7+7+6+6+6+4+4+4 = 44. Need 4.
    // VASE(4).
    Level(
      theme: "Sweet Dreams",
      spangram: "BEDROOM",
      words: ["DRESSER", "CLOSET", "PILLOW", "CARPET", "LAMP", "DESK", "SOFA", "VASE"],
    ),

    // Level 7: Solar System (48 chars)
    // Spangram: UNIVERSE (8)
    // JUPITER(7), MERCURY(7), NEPTUNE(7) -> 21
    // SATURN(6), URANUS(6) -> 12
    // MARS(4) -> 4
    // VENUS(5)? Earth(5)
    // Sum: 8 + 21 + 12 + 4 = 45. Need 3.
    // SUN(3).
    Level(
      theme: "Space Out",
      spangram: "UNIVERSE",
      words: ["JUPITER", "MERCURY", "NEPTUNE", "SATURN", "URANUS", "MARS", "SUN"],
    ),
    
    // Level 8: School Subjects (48 chars)
    // Spangram: LEARNING (8)
    // SCIENCE(7), HISTORY(7), ENGLISH(7) -> 21
    // MATH(4), ART(3)
    // MUSIC(5), DRAMA(5)
    // Sum: 8 + 21 + 4 + 3 + 5 + 5 = 46. Need 2? No words of 2.
    // Let's adjust.
    // LEARNING(8)
    // HISTORY(7)
    // PHYSICS(7)
    // BIOLOGY(7)
    // ALGEBRA(7)
    // MATH(4)
    // ART(3) ... Sum: 8+7+7+7+7+4+3 = 43. 
    // Need 5. MUSIC(5).
    Level(
      theme: "Class Act",
      spangram: "LEARNING",
      words: ["HISTORY", "PHYSICS", "BIOLOGY", "ALGEBRA", "MUSIC", "MATH", "ART"],
    ),

    // Level 9: Fast Food (48 chars)
    // Spangram: CALORIES (8)
    // BURGER(6), FRIES(5), PIZZA(5), TACO(4), SODA(4), SHAKE(5)
    // Sum: 8 + 6 + 5 + 5 + 4 + 4 + 5 = 37.
    // Need 11. 
    // CHICKEN(7). Need 4.
    // CAKE(4).
    Level(
      theme: "Cheat Day",
      spangram: "CALORIES",
      words: ["CHICKEN", "BURGER", "FRIES", "PIZZA", "SHAKE", "TACO", "SODA", "CAKE"],
    ),
    
    // Level 10: Computer Parts (48 chars)
    // Spangram: HARDWARE (8)
    // KEYBOARD(8)
    // MONITOR(7)
    // MOUSE(5)
    // SCREEN(6)
    // LAPTOP(6)
    // CHIP(4)
    // RAM(3)?
    // Sum: 8+8+7+5+6+6+4 = 44. Need 4.
    // DISK(4).
    Level(
      theme: "Tech Specs",
      spangram: "HARDWARE",
      words: ["KEYBOARD", "MONITOR", "SCREEN", "LAPTOP", "MOUSE", "CHIP", "DISK"],
    ),
  ];
}

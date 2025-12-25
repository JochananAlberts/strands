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
    // 1. Healthy Snack (48)
    Level(
      theme: "Healthy Snack",
      spangram: "FRUITSALAD",
      words: ["APPLE", "GRAPE", "MANGO", "MELON", "BERRY", "PEACH", "PEAR", "PLUM"],
    ),
    // 2. Color Palette (48)
    Level(
      theme: "Color Palette",
      spangram: "MIXINGCOLORS",
      words: ["VIOLET", "INDIGO", "ORANGE", "YELLOW", "GREEN", "TEAL", "RED"],
    ),
    // 3. Wild Side (48)
    Level(
      theme: "Wild Side",
      spangram: "JUNGLEANIMALS",
      words: ["TIGER", "ZEBRA", "PANDA", "HIPPO", "RHINO", "COBRA", "OTTER"],
    ),
    // 4. Game On (48)
    Level(
      theme: "Game On",
      spangram: "TEAMSPORTS",
      words: ["SOCCER", "HOCKEY", "TENNIS", "FOOTBALL", "RUGBY", "CRICKET"],
    ),
    // 5. Forecast (48)
    Level(
      theme: "Forecast",
      spangram: "STORMYWEATHER",
      words: ["THUNDER", "LIGHTNING", "RAINY", "WINDY", "CLOUD", "SNOW"],
    ),
    // 6. Interior Design (48)
    Level(
      theme: "Interior Design",
      spangram: "LIVINGROOM",
      words: ["COUCH", "CHAIR", "TABLE", "SHELF", "LAMP", "RUG", "CURTAIN", "VASE"],
    ),
    // 7. Space (48)
    Level(
      theme: "Space",
      spangram: "OUTERSPACE",
      words: ["JUPITER", "SATURN", "URANUS", "NEPTUNE", "MARS", "VENUS", "SUN"],
    ),
    // 8. Education (48)
    Level(
      theme: "Education",
      spangram: "SCHOOLSUBJECTS",
      words: ["MATH", "SCIENCE", "HISTORY", "ENGLISH", "ARTS", "MUSIC"],
    ),
    // 9. Yummy (48)
    Level(
      theme: "Yummy",
      spangram: "FASTFOODCHAIN",
      words: ["BURGER", "FRIES", "PIZZA", "SHAKE", "TACO", "SODA", "NUGGET"],
    ),
    // 10. Hardware (48)
    Level(
      theme: "Hardware",
      spangram: "COMPUTERPARTS",
      words: ["KEYBOARD", "MONITOR", "MOUSE", "SCREEN", "LAPTOP", "CPU"],
    ),
    // 11. Coffee Shop (48) (Spangram: COFFEEHOUSE=11, Words=37)
    Level(
      theme: "Coffee Shop",
      spangram: "COFFEEHOUSE",
      words: ["ESPRESSO", "LATTE", "MOCHA", "BREW", "FOAM", "BEAN", "MUG", "CAFE"],
    ),
    // 12. Camping (48) (Spangram: GREATOUTDOORS=13, Words=35)
    Level(
      theme: "Camping",
      spangram: "GREATOUTDOORS",
      words: ["TENT", "FIRE", "HIKE", "CANOE", "SLEEP", "STARS", "BEAR", "WOOD"],
    ),
    // 13. Instruments (48) (Spangram: ORCHESTRA=9, Words=39)
    Level(
      theme: "Instruments",
      spangram: "ORCHESTRA",
      words: ["VIOLIN", "FLUTE", "HORN", "PIANO", "CELLO", "DRUM", "HARP", "GUITAR"],
    ),
    // 14. Beach Day (48) (Spangram: SANDCASTLE=10, Words=38)
    Level(
      theme: "Beach Day",
      spangram: "SANDCASTLE",
      words: ["OCEAN", "WAVE", "SURF", "SWIM", "CRAB", "SHELL", "SUN", "TOWEL", "SAND"],
    ),
    // 15. Winter (48) (Spangram: SNOWFLAKE=9, Words=39)
    Level(
      theme: "Winter",
      spangram: "SNOWFLAKE",
      words: ["FROST", "ICE", "COLD", "SKI", "SLED", "COAT", "SCARF", "GLOVES", "PARKA"],
    ),
    // 16. Pirates (48) (Spangram: TREASUREHUNT=12, Words=36)
    Level(
      theme: "Pirates",
      spangram: "TREASUREHUNT",
      words: ["SHIP", "GOLD", "MAP", "FLAG", "PARROT", "CREW", "SAIL", "HOOK", "SEA"],
    ),
    // 17. Gardening (48) (Spangram: GREENTHUMB=10, Words=38)
    Level(
      theme: "Gardening",
      spangram: "GREENTHUMB",
      words: ["ROSE", "SOIL", "SEED", "RAKE", "HOSE", "PLANT", "WEED", "SPADE", "ROOT"],
    ),
    // 18. Bakery (48) (Spangram: FRESHBREAD=10, Words=38)
    Level(
      theme: "Bakery",
      spangram: "FRESHBREAD",
      words: ["CAKE", "PIE", "TART", "DUNUT", "BUN", "OVEN", "FLOUR", "SUGAR", "YEAST"],
    ),
    // 19. Zoo (48) (Spangram: ANIMALKINGDOM=13, Words=35)
    Level(
      theme: "Zoo",
      spangram: "ANIMALKINGDOM",
      words: ["LION", "SEAL", "APE", "WOLF", "TIGER", "DEER", "BAT", "FROG", "BIRD"],
    ),
    // 20. Circus (48) (Spangram: BIGTOPCIRCUS=12, Words=36)
    Level(
      theme: "Circus",
      spangram: "BIGTOPCIRCUS",
      words: ["CLOWN", "TENT", "LION", "SHOW", "MAGIC", "TRICK", "MASTER", "FUN"],
    ),
    // 21. Sports (48) (Spangram: ATHLETICS=9, Words=39)
    Level(
      theme: "Sports",
      spangram: "ATHLETICS",
      words: ["RUN", "JUMP", "SWIM", "DIVE", "THROW", "RACE", "WIN", "GOAL", "TEAM", "PLAY"],
    ),
    // 22. Body (48) (Spangram: HUMANANATOMY=12)
    Level(
      theme: "Body",
      spangram: "HUMANANATOMY",
      words: ["HEAD", "ARM", "LEG", "HAND", "FOOT", "EYE", "TONGUE", "NOSE", "MOUTH"],
    ),
    // 23. Fishing (48) (Spangram: GONEFISHING=11, Words=37)
    Level(
      theme: "Fishing",
      spangram: "GONEFISHING",
      words: ["HOOK", "LINE", "BAIT", "ROD", "REEL", "WATER", "BOAT", "LAKE", "TROUT"],
    ),
    // 24. Sewing (48) (Spangram: NEEDLEWORK=10, Words=38)
    Level(
      theme: "Sewing",
      spangram: "NEEDLEWORK",
      words: ["THREAD", "PIN", "YARN", "SILK", "SEAM", "STITCH", "BUTTON", "PATCH"],
    ),
    // 25. Laundry (48) (Spangram: WASHINGMACHINE=14, Words=34)
    Level(
      theme: "Laundry",
      spangram: "WASHINGMACHINE",
      words: ["BLEACH", "SPIN", "DRY", "FOLD", "IRON", "CLEAN", "DIRT", "LOAD"],
    ),
    // 26. Sleep (48) (Spangram: SWEETDREAMS=11, Words=37)
    Level(
      theme: "Sleep",
      spangram: "SWEETDREAMS",
      words: ["BED", "SHEET", "NAP", "REST", "SNORE", "WAKE", "DOZE", "NIGHT", "MOON"],
    ),
    // 27. Flying (48) (Spangram: AVIATION=8, Words=40)
    Level(
      theme: "Flying",
      spangram: "AVIATION",
      words: ["PLANE", "JET", "PILOT", "WING", "SOAR", "CLOUD", "FLY", "AIRPORT", "RIDE"],
    ),
    // 28. Movies (48) (Spangram: BLOCKBUSTER=11, Words=37)
    Level(
      theme: "Movies",
      spangram: "BLOCKBUSTER",
      words: ["ACTOR", "FILM", "PLOT", "SCENE", "STAR", "DRAMA", "ACTION", "EDIT"],
    ),
    // 29. Painting (48) (Spangram: WATERCOLOR=10, Words=38)
    Level(
      theme: "Painting",
      spangram: "WATERCOLOR",
      words: ["BRUSH", "INK", "OIL", "ART", "DRAW", "SKETCH", "PAINT", "EASEL", "MUSE"],
    ),
    // 30. Picnic (48) (Spangram: OUTDOORLUNCH=12, Words=36)
    Level(
      theme: "Picnic",
      spangram: "OUTDOORLUNCH",
      words: ["BASKET", "ANT", "PARK", "FOOD", "COLA", "BLANKET", "SUN", "GRASS"],
    ),
    // 31. Time (48) (Spangram: CLOCKWORK=9, Words=39)
    Level(
      theme: "Time",
      spangram: "CLOCKWORK",
      words: ["HOUR", "MINUTE", "SECOND", "DAY", "WEEK", "MONTH", "YEAR", "PAST", "NOW"],
    ),
    // 32. Money (48) (Spangram: POCKETCHANGE=12, Words=36)
    Level(
      theme: "Money",
      spangram: "POCKETCHANGE",
      words: ["COIN", "CASH", "DOLLAR", "CENT", "PRICE", "BANK", "SAVE", "SPEND"],
    ),
    // 33. Mail (48) (Spangram: POSTOFFICE=10, Words=38)
    Level(
      theme: "Mail",
      spangram: "POSTOFFICE",
      words: ["LETTER", "STAMP", "BOX", "SEND", "MAIL", "SHIP", "PACK", "SIGN", "CARD"],
    ),
    // 34. Farm (48) (Spangram: BARNYARD=8, Words=40)
    Level(
      theme: "Farm",
      spangram: "BARNYARD",
      words: ["COW", "PIG", "HEN", "EGG", "GOAT", "SHEEP", "HAY", "FIELD", "CORN", "TRACTOR"],
    ),
    // 35. Castle (48) (Spangram: ROYALPALACE=11, Words=37)
    Level(
      theme: "Castle",
      spangram: "ROYALPALACE",
      words: ["KING", "QUEEN", "GUARD", "GATE", "WALL", "TOWER", "FLAG", "THRONE"],
    ),
    // 36. Desert (48) (Spangram: SANDSTORM=9, Words=39)
    Level(
      theme: "Desert",
      spangram: "SANDSTORM",
      words: ["CAMEL", "DUNE", "HEAT", "DRY", "CACTUS", "OASIS", "SNAKE", "SUN", "DUST"],
    ),
    // 37. Arctic (48) (Spangram: NORTHPOLE=9, Words=39)
    Level(
      theme: "Arctic",
      spangram: "NORTHPOLE",
      words: ["SNOW", "ICE", "COLD", "BEAR", "SEAL", "FROST", "IGLOO", "WINTER", "SLED"],
    ),
    // 38. Gym (48) (Spangram: WORKOUT=7, Words=41)
    Level(
      theme: "Gym",
      spangram: "WORKOUT",
      words: ["LIFT", "RUN", "SWEAT", "REP", "SET", "BENCH", "SQUAT", "TRAIN", "FIT", "POWER"],
    ),
    // 39. Drinks (48) (Spangram: THIRSTQUENCH=12, Words=36)
    Level(
      theme: "Drinks",
      spangram: "THIRSTQUENCH",
      words: ["WATER", "SODA", "JUICE", "MILK", "TEA", "COCOA", "ICE", "LIME", "CUP"],
    ),
    // 40. Fire (48) (Spangram: BLAZINGFIRE=11, Words=37)
    Level(
      theme: "Fire",
      spangram: "BLAZINGFIRE",
      words: ["HOT", "BURN", "FLAME", "SMOKE", "RED", "GLOW", "HEAT", "SPARK", "COAL"],
    ),
    // 41. Birds (48) (Spangram: FEATHEREDFRIENDS=16, Words=32)
    Level(
      theme: "Birds",
      spangram: "FEATHEREDFRIENDS",
      words: ["WING", "FLY", "NEST", "FLIGHT", "BEAK", "SONG", "SKY", "TREE"],
    ),
    // 42. Pizza (48) (Spangram: MOZZARELLA=10, Words=38)
    Level(
      theme: "Pizza",
      spangram: "MOZZARELLA",
      words: ["CHEESE", "EXTRA", "SAUCE", "CRUST", "SLICE", "TASTE", "OVEN", "HOT"],
    ),
    // 43. Clean (48) (Spangram: SPRINGCLEAN=11, Words=37)
    Level(
      theme: "Clean",
      spangram: "SPRINGCLEAN",
      words: ["WASH", "WIPE", "DUST", "MOP", "SWEEP", "TIDY", "FRESH", "NEAT", "PURE"],
    ),
    // 44. Night (48) (Spangram: MIDNIGHT=8, Words=40)
    Level(
      theme: "Night",
      spangram: "MIDNIGHT",
      words: ["DARK", "MOON", "STAR", "SLEEP", "DREAM", "OWL", "CALM", "BLACK", "SHADOW"],
    ),
    // 45. Travel (48) (Spangram: WORLDTOUR=9, Words=39)
    Level(
      theme: "Travel",
      spangram: "WORLDTOUR",
      words: ["TRIP", "MAP", "BUS", "TRAIN", "CAR", "PLANE", "PACK", "HOTEL", "EXPLORE"],
    ),
    // 46. Hospital (48) (Spangram: HEALTHCARE=10, Words=38)
    Level(
      theme: "Hospital",
      spangram: "HEALTHCARE",
      words: ["DOCTOR", "NURSE", "SICK", "CURE", "BED", "HELP", "WARD", "TEST", "CARE"],
    ),
    // 47. Family (48) (Spangram: FAMILYTREE=10, Words=38)
    Level(
      theme: "Family",
      spangram: "FAMILYTREE",
      words: ["MAMA", "PAPA", "SIS", "BRO", "AUNT", "UNCLE", "LOVE", "HOME", "KIN", "KIDS"],
    ),
    // 48. Party (48) (Spangram: CELEBRATION=11, Words=37)
    Level(
      theme: "Party",
      spangram: "CELEBRATION",
      words: ["FUN", "DANCE", "MUSIC", "GIFT", "CAKE", "BALLOON", "HAPPY", "LOUD"],
    ),
    // 49. Jewelry (48) (Spangram: GEMSTONES=9, Words=39)
    Level(
      theme: "Jewelry",
      spangram: "GEMSTONES",
      words: ["GOLD", "SILVER", "RUBY", "RING", "CHAIN", "PEARL", "SHINE", "LUXURY"],
    ),
    // 50. Happy (48) (Spangram: GOODVIBES=9, Words=39)
    Level(
      theme: "Happy",
      spangram: "GOODVIBES",
      words: ["SMILE", "LAUGH", "HOPE", "GLAD", "KIND", "PEACE", "LOVE", "CALM", "PLAY"],
    ),
  ];
}

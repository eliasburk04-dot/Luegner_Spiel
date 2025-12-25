
/// Categories for Stirnraten game
enum StirnratenCategory {
  anime,
  starWars,
  custom,
}

/// Data class for Stirnraten words
class StirnratenData {
  static const Map<StirnratenCategory, String> categoryNames = {
    StirnratenCategory.anime: 'Anime Edition',
    StirnratenCategory.starWars: 'Star Wars',
    StirnratenCategory.custom: 'Eigene Wörter',
  };

  static const Map<StirnratenCategory, List<String>> words = {
    StirnratenCategory.anime: [
      "Naruto", "One Piece", "Dragon Ball Z", "Attack on Titan", "Death Note",
      "Demon Slayer", "Jujutsu Kaisen", "My Hero Academia", "Fullmetal Alchemist", "Pokemon",
      "Sailor Moon", "Tokyo Ghoul", "Hunter x Hunter", "Bleach", "Fairy Tail",
      "Sword Art Online", "Neon Genesis Evangelion", "Cowboy Bebop", "Spirited Away", "Totoro",
      "One Punch Man", "JoJo's Bizarre Adventure", "Code Geass", "Steins;Gate", "Haikyuu!!",
      "Blue Lock", "Chainsaw Man", "Spy x Family", "Vinland Saga", "Berserk",
      "Ghibli", "Luffy", "Goku", "Pikachu", "Sasuke",
      "Vegeta", "Zoro", "Levi Ackerman", "Light Yagami", "Eren Yeager",
      "Itachi", "Kakashi", "Tanjiro", "Nezuko", "Gojo Satoru"
    ],
    StirnratenCategory.starWars: [
      "Darth Vader", "Luke Skywalker", "Yoda", "Han Solo", "Princess Leia",
      "Chewbacca", "R2-D2", "C-3PO", "Obi-Wan Kenobi", "Anakin Skywalker",
      "Emperor Palpatine", "Darth Maul", "Stormtrooper", "Boba Fett", "Jabba the Hutt",
      "The Mandalorian", "Grogu", "Ahsoka Tano", "Kylo Ren", "Rey",
      "Millennium Falcon", "Death Star", "X-Wing", "TIE Fighter", "Lightsaber",
      "The Force", "Jedi", "Sith", "Tatooine", "Hoth",
      "Ewok", "Wookiee", "Droid", "Clone Trooper", "General Grievous",
      "Count Dooku", "Mace Windu", "Padmé Amidala", "Lando Calrissian", "Admiral Ackbar"
    ],
    StirnratenCategory.custom: [
      "C8", "Monster White", "Dein Vater", "Clash Royale", "Hässlicher Junge", "Weed", "Wlan"
    ],
  };

  static List<String> getWords(StirnratenCategory category) {
    return words[category] ?? [];
  }
}

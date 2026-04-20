class AppConstants {
  AppConstants._();

  static const int maxTargetWords = 8;
  static const int minTargetWords = 2;
  static const int storySentenceCount = 5;
  static const String wordsBoxName = "words";
  static const String storiesBoxName = "stories";
  static const String historyBoxName = "history";
  static const String settingsBoxName = "settings";
  static const String dictionaryCacheBoxName = "dictionary_cache";

  // Dictionary API
  static const String dictionaryBaseUrl =
      "https://api.dictionaryapi.dev/api/v2/entries/en";
}

import "dart:convert";
import "package:flutter/services.dart";
import "package:hive/hive.dart";
import "../../../domain/entities/word.dart";

class HiveDatasource {
  final Box _wordsBox;
  final Box _historyBox;
  final Box _dictionaryCacheBox;

  HiveDatasource({
    required Box wordsBox,
    required Box historyBox,
    required Box dictionaryCacheBox,
  })  : _wordsBox = wordsBox,
        _historyBox = historyBox,
        _dictionaryCacheBox = dictionaryCacheBox;

  // ── Words ──

  /// Load words from JSON asset and store in Hive on first run.
  Future<void> initializeWords() async {
    if (_wordsBox.isNotEmpty) return;

    final jsonStr = await rootBundle.loadString("assets/data/words.json");
    final jsonList = jsonDecode(jsonStr) as List<dynamic>;

    for (final item in jsonList) {
      final word = item as Map<String, dynamic>;
      await _wordsBox.put(word["id"], word);
    }
  }

  Future<List<Word>> getAllWords() async {
    return _wordsBox.values.map((raw) {
      final map = Map<String, dynamic>.from(raw as Map);
      return Word.fromJson(map);
    }).toList();
  }

  Future<List<Word>> getWordsByTopic(String topic) async {
    final all = await getAllWords();
    return all
        .where((w) => w.topic.toLowerCase() == topic.toLowerCase())
        .toList();
  }

  Future<List<String>> getAvailableTopics() async {
    final all = await getAllWords();
    final topics = all.map((w) => w.topic).toSet().toList();
    topics.sort();
    return topics;
  }

  // ── History ──

  Future<void> markWordsLearned(List<Word> words) async {
    final entry = {
      "date": DateTime.now().toIso8601String(),
      "words": words.map((w) => w.toJson()).toList(),
    };
    await _historyBox.add(entry);
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    return _historyBox.values.map((raw) {
      return Map<String, dynamic>.from(raw as Map);
    }).toList();
  }

  Future<void> clearHistory() async {
    await _historyBox.clear();
  }

  // ── Dictionary Cache ──

  Future<Map<String, dynamic>?> getCachedDictionary(String word) async {
    final cached = _dictionaryCacheBox.get(word.toLowerCase());
    if (cached == null) return null;
    return Map<String, dynamic>.from(cached as Map);
  }

  Future<void> cacheDictionary(
      String word, Map<String, dynamic> data) async {
    await _dictionaryCacheBox.put(word.toLowerCase(), data);
  }
}

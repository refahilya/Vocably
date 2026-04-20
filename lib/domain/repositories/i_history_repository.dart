import "../entities/word.dart";

abstract class IHistoryRepository {
  Future<void> markWordsLearned(List<Word> words);
  Future<List<Map<String, dynamic>>> getHistory();
  Future<void> clearHistory();
}

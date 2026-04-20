import "../entities/word.dart";

abstract class IWordRepository {
  Future<List<Word>> getAllWords();
  Future<List<Word>> getWordsByTopic(String topic);
  Future<List<String>> getAvailableTopics();
}

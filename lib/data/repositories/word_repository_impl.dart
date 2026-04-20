import "../../domain/entities/word.dart";
import "../../domain/repositories/i_word_repository.dart";
import "../datasources/local/hive_datasource.dart";

class WordRepositoryImpl implements IWordRepository {
  final HiveDatasource _hiveDatasource;

  WordRepositoryImpl(this._hiveDatasource);

  @override
  Future<List<Word>> getAllWords() => _hiveDatasource.getAllWords();

  @override
  Future<List<Word>> getWordsByTopic(String topic) =>
      _hiveDatasource.getWordsByTopic(topic);

  @override
  Future<List<String>> getAvailableTopics() =>
      _hiveDatasource.getAvailableTopics();
}

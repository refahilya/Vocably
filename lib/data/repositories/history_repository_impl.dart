import "../../domain/entities/word.dart";
import "../../domain/repositories/i_history_repository.dart";
import "../datasources/local/hive_datasource.dart";

class HistoryRepositoryImpl implements IHistoryRepository {
  final HiveDatasource _hiveDatasource;

  HistoryRepositoryImpl(this._hiveDatasource);

  @override
  Future<void> markWordsLearned(List<Word> words) =>
      _hiveDatasource.markWordsLearned(words);

  @override
  Future<List<Map<String, dynamic>>> getHistory() =>
      _hiveDatasource.getHistory();

  @override
  Future<void> clearHistory() => _hiveDatasource.clearHistory();
}

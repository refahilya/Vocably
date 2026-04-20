import "../../domain/entities/dictionary_entry.dart";
import "../../domain/repositories/i_dictionary_repository.dart";
import "../datasources/local/hive_datasource.dart";
import "../datasources/remote/dictionary_datasource.dart";

class DictionaryRepositoryImpl implements IDictionaryRepository {
  final DictionaryDatasource _remoteDatasource;
  final HiveDatasource _localDatasource;

  DictionaryRepositoryImpl(this._remoteDatasource, this._localDatasource);

  @override
  Future<DictionaryEntry> lookupWord(String word) async {
    // Check cache first
    final cached = await _localDatasource.getCachedDictionary(word);
    if (cached != null) {
      return DictionaryEntry.fromApiResponse(cached);
    }

    // Fetch from API
    final entry = await _remoteDatasource.lookupWord(word);

    // Cache the result (re-serialize to store)
    final cacheData = {
      "word": entry.word,
      "phonetic": entry.phonetic,
      "phonetics": entry.audioUrl != null
          ? [{"text": entry.phonetic, "audio": entry.audioUrl}]
          : [{"text": entry.phonetic}],
      "meanings": entry.meanings.map((m) => {
            "partOfSpeech": m.partOfSpeech,
            "definitions": m.definitions
                .map((d) => {
                      "definition": d.definition,
                      if (d.example != null) "example": d.example,
                    })
                .toList(),
          }).toList(),
    };
    await _localDatasource.cacheDictionary(word, cacheData);

    return entry;
  }
}

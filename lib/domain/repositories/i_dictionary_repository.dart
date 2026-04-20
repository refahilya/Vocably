import "../entities/dictionary_entry.dart";

abstract class IDictionaryRepository {
  Future<DictionaryEntry> lookupWord(String word);
}

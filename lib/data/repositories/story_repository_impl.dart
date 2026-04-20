import "package:uuid/uuid.dart";
import "../../domain/entities/story.dart";
import "../../domain/entities/word.dart";
import "../../domain/repositories/i_story_repository.dart";
import "../datasources/remote/gpt_datasource.dart";

class StoryRepositoryImpl implements IStoryRepository {
  final GptDatasource _gptDatasource;
  final _uuid = const Uuid();

  StoryRepositoryImpl(this._gptDatasource);

  @override
  Future<Story> generateStory({
    required List<Word> words,
    required String title,
  }) async {
    final rawText = await _gptDatasource.generateStory(
      words: words,
      title: title,
    );

    // Parse the response: ENGLISH section and INDONESIAN section
    final englishSentences = <String>[];
    final indonesianSentences = <String>[];

    final lines = rawText.split("\n").map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    bool isIndonesian = false;
    for (final line in lines) {
      if (line.toUpperCase().startsWith("ENGLISH")) {
        isIndonesian = false;
        continue;
      }
      if (line.toUpperCase().startsWith("INDONESIAN") ||
          line.toUpperCase().startsWith("INDONESIA")) {
        isIndonesian = true;
        continue;
      }
      // Remove numbering like "1. " or "- "
      final cleaned = line.replaceFirst(RegExp(r"^\d+\.\s*"), "").replaceFirst(RegExp(r"^-\s*"), "").trim();
      if (cleaned.isEmpty) continue;

      if (isIndonesian) {
        indonesianSentences.add(cleaned);
      } else {
        englishSentences.add(cleaned);
      }
    }

    // Fallback: if parsing fails, split by sentences
    if (englishSentences.isEmpty) {
      final fallback = _splitIntoSentences(rawText);
      englishSentences.addAll(fallback);
    }

    return Story(
      id: _uuid.v4(),
      title: title,
      sentences: englishSentences,
      translatedSentences: indonesianSentences,
      targetWords: words,
      generatedAt: DateTime.now(),
    );
  }

  List<String> _splitIntoSentences(String text) {
    return text
        .split(RegExp(r"(?<=[.!?])\s+"))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  @override
  Future<String> infillNextSentence({
    required List<String> previousSentences,
    required List<Word> unusedWords,
    required String storyTitle,
  }) =>
      _gptDatasource.infillNextSentence(
        previousSentences: previousSentences,
        unusedWords: unusedWords,
        storyTitle: storyTitle,
      );

  @override
  Future<Map<String, dynamic>> validateSentence({
    required String userSentence,
    required List<Word> targetWords,
    required List<String> previousSentences,
  }) async {
    final raw = await _gptDatasource.validateSentence(
      userSentence: userSentence,
      targetWords: targetWords,
      previousSentences: previousSentences,
    );

    // Parse response
    final lines = raw.split("\n");
    String wordsUsed = "";
    String grammarOk = "YES";
    String feedback = "";

    for (final line in lines) {
      if (line.startsWith("WORDS_USED:")) {
        wordsUsed = line.replaceFirst("WORDS_USED:", "").trim();
      } else if (line.startsWith("GRAMMAR_OK:")) {
        grammarOk = line.replaceFirst("GRAMMAR_OK:", "").trim();
      } else if (line.startsWith("FEEDBACK:")) {
        feedback = line.replaceFirst("FEEDBACK:", "").trim();
      }
    }

    final usedWordsList = wordsUsed == "NONE"
        ? <String>[]
        : wordsUsed
            .split(",")
            .map((w) => w.trim().toLowerCase())
            .where((w) => w.isNotEmpty)
            .toList();

    return {
      "wordsUsed": usedWordsList,
      "grammarOk": grammarOk.toUpperCase() == "YES",
      "feedback": feedback,
    };
  }

  @override
  Future<String> getHint({
    required List<String> previousSentences,
    required List<Word> unusedWords,
    required String storyTitle,
  }) =>
      _gptDatasource.getHint(
        previousSentences: previousSentences,
        unusedWords: unusedWords,
        storyTitle: storyTitle,
      );
}

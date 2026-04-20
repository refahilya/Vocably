import "../entities/story.dart";
import "../entities/word.dart";

abstract class IStoryRepository {
  Future<Story> generateStory({
    required List<Word> words,
    required String title,
  });

  Future<String> infillNextSentence({
    required List<String> previousSentences,
    required List<Word> unusedWords,
    required String storyTitle,
  });

  Future<Map<String, dynamic>> validateSentence({
    required String userSentence,
    required List<Word> targetWords,
    required List<String> previousSentences,
  });

  Future<String> getHint({
    required List<String> previousSentences,
    required List<Word> unusedWords,
    required String storyTitle,
  });
}

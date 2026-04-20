import "package:equatable/equatable.dart";
import "word.dart";

class Story extends Equatable {
  final String id;
  final String title;
  final List<String> sentences;
  final List<String> translatedSentences;
  final List<Word> targetWords;
  final DateTime generatedAt;

  const Story({
    required this.id,
    required this.title,
    required this.sentences,
    required this.translatedSentences,
    required this.targetWords,
    required this.generatedAt,
  });

  String get fullText => sentences.join(" ");

  bool get allWordsIncluded {
    final text = fullText.toLowerCase();
    return targetWords.every(
      (w) => text.contains(w.english.toLowerCase()),
    );
  }

  @override
  List<Object?> get props => [id];
}

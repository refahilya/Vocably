import "package:equatable/equatable.dart";

enum ClozeStatus { initial, ready, submitted }

class ClozeBlank extends Equatable {
  final int sentenceIndex;
  final int wordIndexInSentence;
  final String correctWord;
  final String? selectedWord;
  final bool? isCorrect;

  const ClozeBlank({
    required this.sentenceIndex,
    required this.wordIndexInSentence,
    required this.correctWord,
    this.selectedWord,
    this.isCorrect,
  });

  ClozeBlank copyWith({
    String? selectedWord,
    bool? isCorrect,
  }) {
    return ClozeBlank(
      sentenceIndex: sentenceIndex,
      wordIndexInSentence: wordIndexInSentence,
      correctWord: correctWord,
      selectedWord: selectedWord ?? this.selectedWord,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }

  @override
  List<Object?> get props =>
      [sentenceIndex, wordIndexInSentence, correctWord, selectedWord, isCorrect];
}

class ClozeState extends Equatable {
  final ClozeStatus status;
  final List<String> sentences;
  final List<ClozeBlank> blanks;
  final List<String> wordOptions;
  final bool allCorrect;

  const ClozeState({
    this.status = ClozeStatus.initial,
    this.sentences = const [],
    this.blanks = const [],
    this.wordOptions = const [],
    this.allCorrect = false,
  });

  bool get isSubmitted => status == ClozeStatus.submitted;
  bool get allFilled => blanks.every((b) => b.selectedWord != null);

  ClozeState copyWith({
    ClozeStatus? status,
    List<String>? sentences,
    List<ClozeBlank>? blanks,
    List<String>? wordOptions,
    bool? allCorrect,
  }) {
    return ClozeState(
      status: status ?? this.status,
      sentences: sentences ?? this.sentences,
      blanks: blanks ?? this.blanks,
      wordOptions: wordOptions ?? this.wordOptions,
      allCorrect: allCorrect ?? this.allCorrect,
    );
  }

  @override
  List<Object?> get props => [status, sentences, blanks, wordOptions, allCorrect];
}

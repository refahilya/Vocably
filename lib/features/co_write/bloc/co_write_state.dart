import "package:equatable/equatable.dart";
import "../../../domain/entities/word.dart";

enum TurnOwner { human, ai }

class CoWriteTurn extends Equatable {
  final String sentence;
  final TurnOwner author;

  const CoWriteTurn({
    required this.sentence,
    required this.author,
  });

  @override
  List<Object?> get props => [sentence, author];
}

enum CoWriteStatus { initial, userTurn, aiWriting, finished, error }

class CoWriteState extends Equatable {
  final CoWriteStatus status;
  final List<Word> allTargetWords;
  final List<Word> usedWords;
  final List<CoWriteTurn> turns;
  final String storyTitle;
  final List<String> hintSentences;
  final String? currentHint;
  final String? feedback;
  final bool feedbackExpanded;
  final bool isValidating;
  final String? errorMessage;

  const CoWriteState({
    this.status = CoWriteStatus.initial,
    this.allTargetWords = const [],
    this.usedWords = const [],
    this.turns = const [],
    this.storyTitle = "",
    this.hintSentences = const [],
    this.currentHint,
    this.feedback,
    this.feedbackExpanded = false,
    this.isValidating = false,
    this.errorMessage,
  });

  List<Word> get unusedWords =>
      allTargetWords.where((w) => !usedWords.contains(w)).toList();

  bool get allWordsUsed => unusedWords.isEmpty;

  CoWriteState copyWith({
    CoWriteStatus? status,
    List<Word>? allTargetWords,
    List<Word>? usedWords,
    List<CoWriteTurn>? turns,
    String? storyTitle,
    List<String>? hintSentences,
    String? currentHint,
    String? feedback,
    bool? feedbackExpanded,
    bool? isValidating,
    String? errorMessage,
    bool clearHint = false,
    bool clearFeedback = false,
  }) {
    return CoWriteState(
      status: status ?? this.status,
      allTargetWords: allTargetWords ?? this.allTargetWords,
      usedWords: usedWords ?? this.usedWords,
      turns: turns ?? this.turns,
      storyTitle: storyTitle ?? this.storyTitle,
      hintSentences: hintSentences ?? this.hintSentences,
      currentHint: clearHint ? null : (currentHint ?? this.currentHint),
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
      feedbackExpanded: feedbackExpanded ?? this.feedbackExpanded,
      isValidating: isValidating ?? this.isValidating,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allTargetWords,
        usedWords,
        turns,
        storyTitle,
        currentHint,
        feedback,
        feedbackExpanded,
        isValidating,
      ];
}

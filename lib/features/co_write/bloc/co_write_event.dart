import "package:equatable/equatable.dart";
import "../../../domain/entities/word.dart";

abstract class CoWriteEvent extends Equatable {
  const CoWriteEvent();
  @override
  List<Object?> get props => [];
}

class CoWriteInitialized extends CoWriteEvent {
  final List<Word> targetWords;
  final String storyTitle;
  final List<String> hintSentences;

  const CoWriteInitialized({
    required this.targetWords,
    required this.storyTitle,
    required this.hintSentences,
  });

  @override
  List<Object?> get props => [targetWords, storyTitle];
}

class CoWriteUserSubmitted extends CoWriteEvent {
  final String sentence;
  const CoWriteUserSubmitted(this.sentence);
  @override
  List<Object?> get props => [sentence];
}

class CoWriteAiTurnRequested extends CoWriteEvent {
  const CoWriteAiTurnRequested();
}

class CoWriteHintRequested extends CoWriteEvent {
  const CoWriteHintRequested();
}

class CoWriteFeedbackDismissed extends CoWriteEvent {
  const CoWriteFeedbackDismissed();
}

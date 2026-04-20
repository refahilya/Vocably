import "package:equatable/equatable.dart";

abstract class ClozeEvent extends Equatable {
  const ClozeEvent();
  @override
  List<Object?> get props => [];
}

class ClozeInitialized extends ClozeEvent {
  final List<String> sentences;
  final List<String> targetWordTexts;

  const ClozeInitialized({
    required this.sentences,
    required this.targetWordTexts,
  });

  @override
  List<Object?> get props => [sentences, targetWordTexts];
}

class ClozeAnswerChanged extends ClozeEvent {
  final int blankIndex;
  final String selectedWord;

  const ClozeAnswerChanged({
    required this.blankIndex,
    required this.selectedWord,
  });

  @override
  List<Object?> get props => [blankIndex, selectedWord];
}

class ClozeSubmitted extends ClozeEvent {
  const ClozeSubmitted();
}

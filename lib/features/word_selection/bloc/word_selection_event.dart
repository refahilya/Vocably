import "package:equatable/equatable.dart";
import "../../../domain/entities/word.dart";

abstract class WordSelectionEvent extends Equatable {
  const WordSelectionEvent();
  @override
  List<Object?> get props => [];
}

class LoadWords extends WordSelectionEvent {
  const LoadWords();
}

class TopicSelected extends WordSelectionEvent {
  final String topic;
  const TopicSelected(this.topic);
  @override
  List<Object?> get props => [topic];
}

class WordTapped extends WordSelectionEvent {
  final Word word;
  const WordTapped(this.word);
  @override
  List<Object?> get props => [word];
}

class WordToggled extends WordSelectionEvent {
  final Word word;
  const WordToggled(this.word);
  @override
  List<Object?> get props => [word];
}

class LookupWord extends WordSelectionEvent {
  final String englishWord;
  const LookupWord(this.englishWord);
  @override
  List<Object?> get props => [englishWord];
}

class DismissDictionary extends WordSelectionEvent {
  const DismissDictionary();
}

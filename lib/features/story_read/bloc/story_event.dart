import "package:equatable/equatable.dart";
import "../../../domain/entities/word.dart";

abstract class StoryEvent extends Equatable {
  const StoryEvent();
  @override
  List<Object?> get props => [];
}

class StoryGenerationRequested extends StoryEvent {
  final List<Word> words;
  final String title;
  const StoryGenerationRequested({required this.words, required this.title});
  @override
  List<Object?> get props => [words, title];
}

class StoryTitleChanged extends StoryEvent {
  final String title;
  const StoryTitleChanged(this.title);
  @override
  List<Object?> get props => [title];
}

class StoryWordTapped extends StoryEvent {
  final Word word;
  const StoryWordTapped(this.word);
  @override
  List<Object?> get props => [word];
}

class StoryTranslationToggled extends StoryEvent {
  const StoryTranslationToggled();
}

import "package:equatable/equatable.dart";
import "../../../domain/entities/story.dart";
import "../../../domain/entities/word.dart";

enum StoryStatus { initial, generating, loaded, error }

class StoryState extends Equatable {
  final StoryStatus status;
  final Story? story;
  final Word? focusedWord;
  final bool showTranslation;
  final String customTitle;
  final String? errorMessage;

  const StoryState({
    this.status = StoryStatus.initial,
    this.story,
    this.focusedWord,
    this.showTranslation = false,
    this.customTitle = "",
    this.errorMessage,
  });

  StoryState copyWith({
    StoryStatus? status,
    Story? story,
    Word? focusedWord,
    bool? showTranslation,
    String? customTitle,
    String? errorMessage,
    bool clearFocusedWord = false,
  }) {
    return StoryState(
      status: status ?? this.status,
      story: story ?? this.story,
      focusedWord: clearFocusedWord ? null : (focusedWord ?? this.focusedWord),
      showTranslation: showTranslation ?? this.showTranslation,
      customTitle: customTitle ?? this.customTitle,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, story, focusedWord, showTranslation, customTitle, errorMessage];
}

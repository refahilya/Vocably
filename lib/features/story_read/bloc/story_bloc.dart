import "package:flutter_bloc/flutter_bloc.dart";
import "../../../domain/repositories/i_story_repository.dart";
import "story_event.dart";
import "story_state.dart";

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final IStoryRepository _storyRepository;

  StoryBloc(this._storyRepository) : super(const StoryState()) {
    on<StoryGenerationRequested>(_onGenerationRequested);
    on<StoryTitleChanged>(_onTitleChanged);
    on<StoryWordTapped>(_onWordTapped);
    on<StoryTranslationToggled>(_onTranslationToggled);
  }

  Future<void> _onGenerationRequested(
    StoryGenerationRequested event,
    Emitter<StoryState> emit,
  ) async {
    emit(state.copyWith(
      status: StoryStatus.generating,
      customTitle: event.title,
    ));
    try {
      final story = await _storyRepository.generateStory(
        words: event.words,
        title: event.title,
      );
      emit(state.copyWith(status: StoryStatus.loaded, story: story));
    } catch (e) {
      emit(state.copyWith(
        status: StoryStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onTitleChanged(
    StoryTitleChanged event,
    Emitter<StoryState> emit,
  ) {
    emit(state.copyWith(customTitle: event.title));
  }

  void _onWordTapped(
    StoryWordTapped event,
    Emitter<StoryState> emit,
  ) {
    if (state.focusedWord?.id == event.word.id) {
      emit(state.copyWith(clearFocusedWord: true));
    } else {
      emit(state.copyWith(focusedWord: event.word));
    }
  }

  void _onTranslationToggled(
    StoryTranslationToggled event,
    Emitter<StoryState> emit,
  ) {
    emit(state.copyWith(showTranslation: !state.showTranslation));
  }
}

import "package:flutter_bloc/flutter_bloc.dart";
import "../../../core/constants/app_constants.dart";
import "../../../domain/repositories/i_word_repository.dart";
import "../../../domain/repositories/i_dictionary_repository.dart";
import "word_selection_event.dart";
import "word_selection_state.dart";

class WordSelectionBloc extends Bloc<WordSelectionEvent, WordSelectionState> {
  final IWordRepository _wordRepository;
  final IDictionaryRepository _dictionaryRepository;

  WordSelectionBloc(this._wordRepository, this._dictionaryRepository)
      : super(const WordSelectionState()) {
    on<LoadWords>(_onLoadWords);
    on<TopicSelected>(_onTopicSelected);
    on<WordTapped>(_onWordTapped);
    on<WordToggled>(_onWordToggled);
    on<LookupWord>(_onLookupWord);
    on<DismissDictionary>(_onDismissDictionary);
  }

  Future<void> _onLoadWords(
    LoadWords event,
    Emitter<WordSelectionState> emit,
  ) async {
    emit(state.copyWith(status: WordSelectionStatus.loading));
    try {
      final topics = await _wordRepository.getAvailableTopics();
      if (topics.isNotEmpty) {
        final words = await _wordRepository.getWordsByTopic(topics.first);
        emit(state.copyWith(
          status: WordSelectionStatus.loaded,
          availableTopics: topics,
          selectedTopic: topics.first,
          wordsForTopic: words,
        ));
      } else {
        emit(state.copyWith(
          status: WordSelectionStatus.loaded,
          availableTopics: topics,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: WordSelectionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onTopicSelected(
    TopicSelected event,
    Emitter<WordSelectionState> emit,
  ) async {
    emit(state.copyWith(status: WordSelectionStatus.loading));
    try {
      final words = await _wordRepository.getWordsByTopic(event.topic);
      emit(state.copyWith(
        status: WordSelectionStatus.loaded,
        selectedTopic: event.topic,
        wordsForTopic: words,
        selectedWords: const [],
        clearDictionary: true,
        clearTappedWord: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WordSelectionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onWordTapped(
    WordTapped event,
    Emitter<WordSelectionState> emit,
  ) {
    emit(state.copyWith(
      tappedWord: event.word,
      isDictionaryLoading: true,
      clearDictionary: true,
    ));
    add(LookupWord(event.word.english));
  }

  void _onWordToggled(
    WordToggled event,
    Emitter<WordSelectionState> emit,
  ) {
    final isSelected = state.selectedWords.contains(event.word);
    if (isSelected) {
      emit(state.copyWith(
        selectedWords: state.selectedWords
            .where((w) => w.id != event.word.id)
            .toList(),
      ));
    } else {
      if (state.selectedWords.length >= AppConstants.maxTargetWords) return;
      emit(state.copyWith(
        selectedWords: [...state.selectedWords, event.word],
      ));
    }
  }

  Future<void> _onLookupWord(
    LookupWord event,
    Emitter<WordSelectionState> emit,
  ) async {
    try {
      final entry = await _dictionaryRepository.lookupWord(event.englishWord);
      emit(state.copyWith(
        dictionaryEntry: entry,
        isDictionaryLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isDictionaryLoading: false));
    }
  }

  void _onDismissDictionary(
    DismissDictionary event,
    Emitter<WordSelectionState> emit,
  ) {
    emit(state.copyWith(
      clearDictionary: true,
      clearTappedWord: true,
    ));
  }
}

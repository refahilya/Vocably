import "package:equatable/equatable.dart";
import "../../../domain/entities/word.dart";
import "../../../domain/entities/dictionary_entry.dart";

enum WordSelectionStatus { initial, loading, loaded, error }

class WordSelectionState extends Equatable {
  final WordSelectionStatus status;
  final List<String> availableTopics;
  final String selectedTopic;
  final List<Word> wordsForTopic;
  final List<Word> selectedWords;
  final DictionaryEntry? dictionaryEntry;
  final Word? tappedWord;
  final bool isDictionaryLoading;
  final String? errorMessage;

  const WordSelectionState({
    this.status = WordSelectionStatus.initial,
    this.availableTopics = const [],
    this.selectedTopic = "",
    this.wordsForTopic = const [],
    this.selectedWords = const [],
    this.dictionaryEntry,
    this.tappedWord,
    this.isDictionaryLoading = false,
    this.errorMessage,
  });

  bool get canStartLearning => selectedWords.length >= 2;

  WordSelectionState copyWith({
    WordSelectionStatus? status,
    List<String>? availableTopics,
    String? selectedTopic,
    List<Word>? wordsForTopic,
    List<Word>? selectedWords,
    DictionaryEntry? dictionaryEntry,
    Word? tappedWord,
    bool? isDictionaryLoading,
    String? errorMessage,
    bool clearDictionary = false,
    bool clearTappedWord = false,
  }) =>
      WordSelectionState(
        status: status ?? this.status,
        availableTopics: availableTopics ?? this.availableTopics,
        selectedTopic: selectedTopic ?? this.selectedTopic,
        wordsForTopic: wordsForTopic ?? this.wordsForTopic,
        selectedWords: selectedWords ?? this.selectedWords,
        dictionaryEntry:
            clearDictionary ? null : (dictionaryEntry ?? this.dictionaryEntry),
        tappedWord:
            clearTappedWord ? null : (tappedWord ?? this.tappedWord),
        isDictionaryLoading: isDictionaryLoading ?? this.isDictionaryLoading,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [
        status,
        availableTopics,
        selectedTopic,
        wordsForTopic,
        selectedWords,
        dictionaryEntry,
        tappedWord,
        isDictionaryLoading,
      ];
}

import "package:flutter_bloc/flutter_bloc.dart";
import "../../../domain/entities/word.dart";
import "../../../domain/repositories/i_story_repository.dart";
import "co_write_event.dart";
import "co_write_state.dart";

class CoWriteBloc extends Bloc<CoWriteEvent, CoWriteState> {
  final IStoryRepository _storyRepository;

  CoWriteBloc(this._storyRepository) : super(const CoWriteState()) {
    on<CoWriteInitialized>(_onInitialized);
    on<CoWriteUserSubmitted>(_onUserSubmitted);
    on<CoWriteAiTurnRequested>(_onAiTurnRequested);
    on<CoWriteHintRequested>(_onHintRequested);
    on<CoWriteFeedbackDismissed>(_onFeedbackDismissed);
  }

  void _onInitialized(
    CoWriteInitialized event,
    Emitter<CoWriteState> emit,
  ) {
    emit(state.copyWith(
      status: CoWriteStatus.userTurn,
      allTargetWords: event.targetWords,
      storyTitle: event.storyTitle,
      hintSentences: event.hintSentences,
      usedWords: const [],
      turns: const [],
    ));
  }

  Future<void> _onUserSubmitted(
    CoWriteUserSubmitted event,
    Emitter<CoWriteState> emit,
  ) async {
    if (event.sentence.trim().isEmpty) return;

    emit(state.copyWith(isValidating: true, clearFeedback: true));

    try {
      // Validate sentence via AI
      final result = await _storyRepository.validateSentence(
        userSentence: event.sentence,
        targetWords: state.unusedWords,
        previousSentences: state.turns.map((t) => t.sentence).toList(),
      );

      final wordsUsedStrings = (result["wordsUsed"] as List<dynamic>?) ?? [];
      final grammarOk = result["grammarOk"] as bool? ?? true;
      final feedback = result["feedback"] as String? ?? "";

      // Find which target words were used (case-insensitive match)
      final newlyUsed = <Word>[];
      final sentenceLower = event.sentence.toLowerCase();
      for (final word in state.unusedWords) {
        if (sentenceLower.contains(word.english.toLowerCase())) {
          newlyUsed.add(word);
        }
      }

      // Also check AI response for used words
      for (final usedStr in wordsUsedStrings) {
        final match = state.unusedWords.cast<Word?>().firstWhere(
              (w) => w!.english.toLowerCase() == usedStr.toString().toLowerCase(),
              orElse: () => null,
            );
        if (match != null && !newlyUsed.contains(match)) {
          newlyUsed.add(match);
        }
      }

      final updatedUsed = [...state.usedWords, ...newlyUsed];
      final updatedTurns = [
        ...state.turns,
        CoWriteTurn(sentence: event.sentence, author: TurnOwner.human),
      ];

      final allDone = updatedUsed.length >= state.allTargetWords.length;

      String displayFeedback = "";
      if (!grammarOk) {
        displayFeedback = "⚠️ $feedback";
      } else if (newlyUsed.isEmpty) {
        displayFeedback =
            "⚠️ Kalimatmu belum menggunakan kata target. Coba gunakan salah satu kata yang tersedia.";
      } else {
        displayFeedback =
            "✅ Bagus! Kata yang digunakan: ${newlyUsed.map((w) => w.english).join(', ')}";
      }

      emit(state.copyWith(
        status: allDone ? CoWriteStatus.finished : CoWriteStatus.aiWriting,
        usedWords: updatedUsed,
        turns: updatedTurns,
        feedback: displayFeedback,
        isValidating: false,
      ));

      // Auto-trigger AI turn if not finished
      if (!allDone) {
        add(const CoWriteAiTurnRequested());
      }
    } catch (e) {
      // Fallback: do simple local check
      final newlyUsed = <Word>[];
      final sentenceLower = event.sentence.toLowerCase();
      for (final word in state.unusedWords) {
        if (sentenceLower.contains(word.english.toLowerCase())) {
          newlyUsed.add(word);
        }
      }

      final updatedUsed = [...state.usedWords, ...newlyUsed];
      final updatedTurns = [
        ...state.turns,
        CoWriteTurn(sentence: event.sentence, author: TurnOwner.human),
      ];
      final allDone = updatedUsed.length >= state.allTargetWords.length;

      emit(state.copyWith(
        status: allDone ? CoWriteStatus.finished : CoWriteStatus.aiWriting,
        usedWords: updatedUsed,
        turns: updatedTurns,
        feedback: newlyUsed.isEmpty
            ? "⚠️ Kalimatmu belum menggunakan kata target."
            : "✅ Kata: ${newlyUsed.map((w) => w.english).join(', ')}",
        isValidating: false,
      ));

      if (!allDone) {
        add(const CoWriteAiTurnRequested());
      }
    }
  }

  Future<void> _onAiTurnRequested(
    CoWriteAiTurnRequested event,
    Emitter<CoWriteState> emit,
  ) async {
    try {
      final aiSentence = await _storyRepository.infillNextSentence(
        previousSentences: state.turns.map((t) => t.sentence).toList(),
        unusedWords: state.unusedWords,
        storyTitle: state.storyTitle,
      );

      // Check which words AI used
      final aiUsed = <Word>[];
      final aiLower = aiSentence.toLowerCase();
      for (final word in state.unusedWords) {
        if (aiLower.contains(word.english.toLowerCase())) {
          aiUsed.add(word);
        }
      }

      final updatedUsed = [...state.usedWords, ...aiUsed];
      final updatedTurns = [
        ...state.turns,
        CoWriteTurn(sentence: aiSentence, author: TurnOwner.ai),
      ];
      final allDone = updatedUsed.length >= state.allTargetWords.length;

      emit(state.copyWith(
        status: allDone ? CoWriteStatus.finished : CoWriteStatus.userTurn,
        usedWords: updatedUsed,
        turns: updatedTurns,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CoWriteStatus.userTurn,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onHintRequested(
    CoWriteHintRequested event,
    Emitter<CoWriteState> emit,
  ) async {
    // First try using the stored hint sentences
    if (state.hintSentences.isNotEmpty) {
      final hintIndex = state.turns.length ~/ 2;
      if (hintIndex < state.hintSentences.length) {
        emit(state.copyWith(currentHint: "💡 Coba: \"${state.hintSentences[hintIndex]}\""));
        return;
      }
    }

    // Fall back to AI hint
    try {
      final hint = await _storyRepository.getHint(
        previousSentences: state.turns.map((t) => t.sentence).toList(),
        unusedWords: state.unusedWords,
        storyTitle: state.storyTitle,
      );
      emit(state.copyWith(currentHint: "💡 Coba: \"$hint\""));
    } catch (e) {
      emit(state.copyWith(
          currentHint: "💡 Coba gunakan kata '${state.unusedWords.first.english}' dalam kalimatmu."));
    }
  }

  void _onFeedbackDismissed(
    CoWriteFeedbackDismissed event,
    Emitter<CoWriteState> emit,
  ) {
    emit(state.copyWith(clearFeedback: true, clearHint: true));
  }
}

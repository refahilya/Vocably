import "package:flutter_bloc/flutter_bloc.dart";
import "cloze_event.dart";
import "cloze_state.dart";

class ClozeBloc extends Bloc<ClozeEvent, ClozeState> {
  ClozeBloc() : super(const ClozeState()) {
    on<ClozeInitialized>(_onInitialized);
    on<ClozeAnswerChanged>(_onAnswerChanged);
    on<ClozeSubmitted>(_onSubmitted);
  }

  void _onInitialized(
    ClozeInitialized event,
    Emitter<ClozeState> emit,
  ) {
    final blanks = <ClozeBlank>[];
    final targetWordsLower =
        event.targetWordTexts.map((w) => w.toLowerCase()).toSet();

    for (int si = 0; si < event.sentences.length; si++) {
      final words = event.sentences[si].split(" ");
      for (int wi = 0; wi < words.length; wi++) {
        final cleaned =
            words[wi].replaceAll(RegExp(r"[^a-zA-Z]"), "").toLowerCase();
        if (targetWordsLower.contains(cleaned)) {
          blanks.add(ClozeBlank(
            sentenceIndex: si,
            wordIndexInSentence: wi,
            correctWord: cleaned,
          ));
        }
      }
    }

    // Shuffle word options
    final options = event.targetWordTexts.toList()..shuffle();

    emit(state.copyWith(
      status: ClozeStatus.ready,
      sentences: event.sentences,
      blanks: blanks,
      wordOptions: options,
    ));
  }

  void _onAnswerChanged(
    ClozeAnswerChanged event,
    Emitter<ClozeState> emit,
  ) {
    final updatedBlanks = state.blanks.toList();
    updatedBlanks[event.blankIndex] = updatedBlanks[event.blankIndex].copyWith(
      selectedWord: event.selectedWord,
    );
    emit(state.copyWith(blanks: updatedBlanks));
  }

  void _onSubmitted(
    ClozeSubmitted event,
    Emitter<ClozeState> emit,
  ) {
    final checkedBlanks = state.blanks.map((blank) {
      final isCorrect =
          blank.selectedWord?.toLowerCase() == blank.correctWord.toLowerCase();
      return ClozeBlank(
        sentenceIndex: blank.sentenceIndex,
        wordIndexInSentence: blank.wordIndexInSentence,
        correctWord: blank.correctWord,
        selectedWord: blank.selectedWord,
        isCorrect: isCorrect,
      );
    }).toList();

    final allCorrect = checkedBlanks.every((b) => b.isCorrect == true);

    emit(state.copyWith(
      status: ClozeStatus.submitted,
      blanks: checkedBlanks,
      allCorrect: allCorrect,
    ));
  }
}

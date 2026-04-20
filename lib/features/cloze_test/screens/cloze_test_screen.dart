import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:gap/gap.dart";
import "../../../core/theme/app_theme.dart";
import "../../../core/di/injection.dart";
import "../../../domain/entities/story.dart";
import "../../../domain/entities/word.dart";
import "../../../domain/repositories/i_story_repository.dart";
import "../../co_write/bloc/co_write_bloc.dart";
import "../../co_write/bloc/co_write_event.dart";
import "../../co_write/screens/co_write_screen.dart";
import "../bloc/cloze_bloc.dart";
import "../bloc/cloze_state.dart";
import "../bloc/cloze_event.dart";

class ClozeTestScreen extends StatelessWidget {
  final Story story;
  final List<Word> targetWords;

  const ClozeTestScreen({
    super.key,
    required this.story,
    required this.targetWords,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cloze Test"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: _ProgressBar(currentStep: 1),
        ),
      ),
      body: BlocBuilder<ClozeBloc, ClozeState>(
        builder: (context, state) {
          if (state.status == ClozeStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Instructions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.wordBubble,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppTheme.primary, size: 20),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        "Isi bagian yang kosong dengan kata yang tepat dari pilihan yang tersedia.",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              // Story with blanks
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ClozeStoryText(
                    sentences: state.sentences,
                    blanks: state.blanks,
                    wordOptions: state.wordOptions,
                    isSubmitted: state.isSubmitted,
                  ),
                ),
              ),

              // Result banner
              if (state.isSubmitted)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: state.allCorrect
                        ? AppTheme.success.withValues(alpha: 0.1)
                        : AppTheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: state.allCorrect
                          ? AppTheme.success.withValues(alpha: 0.3)
                          : AppTheme.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        state.allCorrect
                            ? Icons.check_circle
                            : Icons.info_outline,
                        color: state.allCorrect
                            ? AppTheme.success
                            : AppTheme.error,
                      ),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          state.allCorrect
                              ? "🎉 Semua jawaban benar! Lanjut ke tahap berikutnya."
                              : "Ada jawaban yang salah. Jawaban yang benar ditandai hijau.",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: state.allCorrect
                                ? AppTheme.success
                                : AppTheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),

              // Buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (!state.isSubmitted)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: state.allFilled
                              ? () {
                                  context
                                      .read<ClozeBloc>()
                                      .add(const ClozeSubmitted());
                                }
                              : null,
                          icon: const Icon(Icons.check),
                          label: const Text("Submit"),
                        ),
                      ),
                    if (state.isSubmitted) ...[
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) =>
                                    CoWriteBloc(getIt<IStoryRepository>())
                                      ..add(CoWriteInitialized(
                                        targetWords: targetWords,
                                        storyTitle: story.title,
                                        hintSentences: story.sentences,
                                      )),
                                child: CoWriteScreen(
                                  targetWords: targetWords,
                                  storyTitle: story.title,
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text("Selanjutnya"),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Progress bar (reused pattern) ──
class _ProgressBar extends StatelessWidget {
  final int currentStep;
  const _ProgressBar({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = ["Membaca", "Cloze Test", "Co-Write"];
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i <= currentStep;
          final isCurrent = i == currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.3),
                  ),
                  child: Center(
                    child: i < currentStep
                        ? const Icon(Icons.check,
                            size: 14, color: AppTheme.primary)
                        : Text(
                            "${i + 1}",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isActive
                                  ? AppTheme.primary
                                  : Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                  ),
                ),
                const Gap(4),
                Expanded(
                  child: Text(
                    steps[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isCurrent ? FontWeight.w700 : FontWeight.w400,
                      color: isActive
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (i < steps.length - 1)
                  Container(
                    width: 12,
                    height: 1.5,
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.2),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Story text with dropdown blanks ──
class _ClozeStoryText extends StatelessWidget {
  final List<String> sentences;
  final List<ClozeBlank> blanks;
  final List<String> wordOptions;
  final bool isSubmitted;

  const _ClozeStoryText({
    required this.sentences,
    required this.blanks,
    required this.wordOptions,
    required this.isSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sentences.asMap().entries.map((entry) {
        final si = entry.key;
        final sentence = entry.value;
        final words = sentence.split(" ");
        final sentenceBlanks =
            blanks.where((b) => b.sentenceIndex == si).toList();

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Wrap(
            spacing: 4,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: words.asMap().entries.map((wordEntry) {
              final wi = wordEntry.key;
              final wordText = wordEntry.value;

              final blankMatch = sentenceBlanks.cast<ClozeBlank?>().firstWhere(
                    (b) => b!.wordIndexInSentence == wi,
                    orElse: () => null,
                  );

              if (blankMatch != null) {
                final blankIndex = blanks.indexOf(blankMatch);
                return _ClozeDropdown(
                  blank: blankMatch,
                  blankIndex: blankIndex,
                  options: wordOptions,
                  isSubmitted: isSubmitted,
                );
              }

              return Text(
                wordText,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.8,
                  color: AppTheme.textPrimary,
                ),
              );
            }).toList(),
          ),
        ).animate().fadeIn(delay: (100 * si).ms, duration: 300.ms);
      }).toList(),
    );
  }
}

// ── Dropdown for a blank ──
class _ClozeDropdown extends StatelessWidget {
  final ClozeBlank blank;
  final int blankIndex;
  final List<String> options;
  final bool isSubmitted;

  const _ClozeDropdown({
    required this.blank,
    required this.blankIndex,
    required this.options,
    required this.isSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bgColor;

    if (isSubmitted && blank.isCorrect == true) {
      borderColor = AppTheme.success;
      bgColor = AppTheme.success.withValues(alpha: 0.1);
    } else if (isSubmitted && blank.isCorrect == false) {
      borderColor = AppTheme.error;
      bgColor = AppTheme.error.withValues(alpha: 0.1);
    } else {
      borderColor = AppTheme.primary;
      bgColor = AppTheme.wordBubble;
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 100),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: blank.selectedWord,
          hint: const Text("___",
              style: TextStyle(color: AppTheme.primary, fontSize: 14)),
          isDense: true,
          isExpanded: false,
          items: options
              .map((w) => DropdownMenuItem(
                    value: w.toLowerCase(),
                    child: Text(w, style: const TextStyle(fontSize: 14)),
                  ))
              .toList(),
          onChanged: isSubmitted
              ? null
              : (val) {
                  if (val != null) {
                    context.read<ClozeBloc>().add(ClozeAnswerChanged(
                          blankIndex: blankIndex,
                          selectedWord: val,
                        ));
                  }
                },
        ),
      ),
    );
  }
}

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:gap/gap.dart";
import "../../../core/theme/app_theme.dart";
import "../../../core/utils/word_highlighter.dart";
import "../../../domain/entities/word.dart";
import "../../../domain/entities/story.dart";
import "../../cloze_test/bloc/cloze_bloc.dart";
import "../../cloze_test/bloc/cloze_event.dart";
import "../../cloze_test/screens/cloze_test_screen.dart";
import "../bloc/story_bloc.dart";
import "../bloc/story_event.dart";
import "../bloc/story_state.dart";

class StoryReadScreen extends StatefulWidget {
  final List<Word> targetWords;
  final String initialTitle;

  const StoryReadScreen({
    super.key,
    required this.targetWords,
    required this.initialTitle,
  });

  @override
  State<StoryReadScreen> createState() => _StoryReadScreenState();
}

class _StoryReadScreenState extends State<StoryReadScreen> {
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    // Auto-generate on first load
    context.read<StoryBloc>().add(StoryGenerationRequested(
          words: widget.targetWords,
          title: widget.initialTitle,
        ));
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Baca Cerita"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: _ProgressIndicator(currentStep: 0),
        ),
      ),
      body: BlocBuilder<StoryBloc, StoryState>(
        builder: (context, state) {
          return Column(
            children: [
              // Title input + generate button
              _TitleBar(
                controller: _titleController,
                isGenerating: state.status == StoryStatus.generating,
                onGenerate: () {
                  context.read<StoryBloc>().add(StoryGenerationRequested(
                        words: widget.targetWords,
                        title: _titleController.text.isNotEmpty
                            ? _titleController.text
                            : widget.initialTitle,
                      ));
                },
              ),

              // Story content
              Expanded(
                child: state.status == StoryStatus.generating
                    ? _LoadingStory()
                    : state.status == StoryStatus.error
                        ? _ErrorView(message: state.errorMessage ?? "Error")
                        : state.story == null
                            ? const Center(
                                child: Text("Tekan generate untuk membuat cerita"))
                            : _StoryContent(
                                story: state.story!,
                                focusedWord: state.focusedWord,
                                showTranslation: state.showTranslation,
                              ),
              ),

              // Translation toggle + Next
              if (state.story != null)
                _BottomActions(
                  showTranslation: state.showTranslation,
                  story: state.story!,
                  targetWords: widget.targetWords,
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Progress indicator ──
class _ProgressIndicator extends StatelessWidget {
  final int currentStep;
  const _ProgressIndicator({required this.currentStep});

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
                    child: isActive && !isCurrent
                        ? const Icon(Icons.check, size: 14, color: AppTheme.primary)
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
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
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

// ── Title bar ──
class _TitleBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isGenerating;
  final VoidCallback onGenerate;

  const _TitleBar({
    required this.controller,
    required this.isGenerating,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Judul/topik cerita...",
                prefixIcon: const Icon(Icons.edit_outlined, size: 20),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const Gap(8),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: isGenerating ? null : onGenerate,
              icon: isGenerating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_fix_high, size: 18),
              label: Text(isGenerating ? "..." : "Generate"),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading state ──
class _LoadingStory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.primary),
          const Gap(16),
          Text(
            "Menghasilkan cerita...",
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ).animate(onPlay: (c) => c.repeat()).fadeIn().then().fadeOut(),
        ],
      ),
    );
  }
}

// ── Error view ──
class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
            const Gap(16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.error),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Story content with highlighted words ──
class _StoryContent extends StatelessWidget {
  final Story story;
  final Word? focusedWord;
  final bool showTranslation;

  const _StoryContent({
    required this.story,
    this.focusedWord,
    required this.showTranslation,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Story title
          Text(
            story.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ).animate().fadeIn(duration: 400.ms),
          const Gap(16),

          // Story sentences with highlighted words
          ...story.sentences.asMap().entries.map((entry) {
            final index = entry.key;
            final sentence = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: WordHighlighter.buildHighlightedSpans(
                        text: sentence,
                        targetWords: story.targetWords,
                        onWordTap: (word) {
                          context
                              .read<StoryBloc>()
                              .add(StoryWordTapped(word));
                        },
                      ),
                    ),
                  ),
                  if (showTranslation &&
                      index < story.translatedSentences.length)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        story.translatedSentences[index],
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.secondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ).animate().fadeIn(delay: (150 * index).ms, duration: 400.ms);
          }),

          // Focused word detail
          if (focusedWord != null) ...[
            const Gap(12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        focusedWord!.english,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        "🇮🇩 ${focusedWord!.indonesian}",
                        style: const TextStyle(
                            fontSize: 14, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 200.ms).scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1, 1),
                ),
          ],
        ],
      ),
    );
  }
}

// ── Bottom actions ──
class _BottomActions extends StatelessWidget {
  final bool showTranslation;
  final Story story;
  final List<Word> targetWords;

  const _BottomActions({
    required this.showTranslation,
    required this.story,
    required this.targetWords,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Translation toggle
          OutlinedButton.icon(
            onPressed: () {
              context
                  .read<StoryBloc>()
                  .add(const StoryTranslationToggled());
            },
            icon: Icon(
              showTranslation
                  ? Icons.visibility_off
                  : Icons.translate,
              size: 18,
            ),
            label: Text(showTranslation ? "Sembunyikan" : "Terjemahan"),
          ),
          const Spacer(),
          // Next button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => ClozeBloc()
                      ..add(ClozeInitialized(
                        sentences: story.sentences,
                        targetWordTexts:
                            targetWords.map((w) => w.english).toList(),
                      )),
                    child: ClozeTestScreen(
                      story: story,
                      targetWords: targetWords,
                    ),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text("Selanjutnya"),
          ),
        ],
      ),
    );
  }
}

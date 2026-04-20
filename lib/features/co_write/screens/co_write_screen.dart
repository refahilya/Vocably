import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:gap/gap.dart";
import "../../../core/theme/app_theme.dart";
import "../../../core/di/injection.dart";
import "../../../domain/entities/word.dart";
import "../../../domain/repositories/i_history_repository.dart";
import "../bloc/co_write_bloc.dart";
import "../bloc/co_write_event.dart";
import "../bloc/co_write_state.dart";

class CoWriteScreen extends StatefulWidget {
  final List<Word> targetWords;
  final String storyTitle;

  const CoWriteScreen({
    super.key,
    required this.targetWords,
    required this.storyTitle,
  });

  @override
  State<CoWriteScreen> createState() => _CoWriteScreenState();
}

class _CoWriteScreenState extends State<CoWriteScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tulis Bersama AI"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: _ProgressBar(currentStep: 2),
        ),
      ),
      body: BlocConsumer<CoWriteBloc, CoWriteState>(
        listener: (context, state) {
          if (state.turns.isNotEmpty) _scrollToBottom();
        },
        builder: (context, state) {
          return Column(
            children: [
              // Word tracker bubbles
              _WordTracker(
                allWords: state.allTargetWords,
                usedWords: state.usedWords,
              ),

              // Chat area
              Expanded(
                child: state.turns.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_note,
                                  size: 48,
                                  color: AppTheme.primary.withValues(alpha: 0.4)),
                              const Gap(12),
                              Text(
                                "Mulai menulis kalimat pertama!\nGunakan salah satu kata target di atas.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: state.turns.length,
                        itemBuilder: (context, index) {
                          final turn = state.turns[index];
                          return _ChatBubble(
                            sentence: turn.sentence,
                            isUser: turn.author == TurnOwner.human,
                            index: index,
                          );
                        },
                      ),
              ),

              // Hint display
              if (state.currentHint != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.accent.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    state.currentHint!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ).animate().fadeIn(duration: 200.ms),

              // Feedback area
              if (state.feedback != null)
                GestureDetector(
                  onTap: () => context
                      .read<CoWriteBloc>()
                      .add(const CoWriteFeedbackDismissed()),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: state.feedback!.startsWith("✅")
                          ? AppTheme.success.withValues(alpha: 0.1)
                          : AppTheme.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      state.feedback!,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ).animate().fadeIn(duration: 200.ms),

              // Input area or finish
              if (state.status == CoWriteStatus.finished)
                _FinishBar(targetWords: widget.targetWords)
              else if (state.status == CoWriteStatus.aiWriting)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const Gap(12),
                      Text(
                        "AI sedang menulis...",
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                )
              else
                _InputBar(
                  controller: _textController,
                  isValidating: state.isValidating,
                  onSubmit: () {
                    final text = _textController.text.trim();
                    if (text.isNotEmpty) {
                      context
                          .read<CoWriteBloc>()
                          .add(CoWriteUserSubmitted(text));
                      _textController.clear();
                    }
                  },
                  onHint: () {
                    context
                        .read<CoWriteBloc>()
                        .add(const CoWriteHintRequested());
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Progress bar ──
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

// ── Word tracker ──
class _WordTracker extends StatelessWidget {
  final List<Word> allWords;
  final List<Word> usedWords;

  const _WordTracker({required this.allWords, required this.usedWords});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppTheme.softShadow,
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: allWords.map((word) {
          final isUsed = usedWords.contains(word);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isUsed ? AppTheme.wordUsed : AppTheme.wordUnused,
              borderRadius: AppTheme.chipRadius,
            ),
            child: Text(
              word.english,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isUsed ? Colors.white : Colors.grey.shade600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Chat bubble ──
class _ChatBubble extends StatelessWidget {
  final String sentence;
  final bool isUser;
  final int index;

  const _ChatBubble({
    required this.sentence,
    required this.isUser,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isUser
                  ? const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryLight],
                    )
                  : const LinearGradient(
                      colors: [AppTheme.secondary, Color(0xFF26C6DA)],
                    ),
            ),
            child: Icon(
              isUser ? Icons.person : Icons.smart_toy,
              size: 18,
              color: Colors.white,
            ),
          ),
          const Gap(10),
          // Message
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser
                    ? AppTheme.wordBubble
                    : AppTheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                sentence,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: isUser ? -0.05 : 0.05);
  }
}

// ── Input bar ──
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isValidating;
  final VoidCallback onSubmit;
  final VoidCallback onHint;

  const _InputBar({
    required this.controller,
    required this.isValidating,
    required this.onSubmit,
    required this.onHint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Hint button
              IconButton(
                icon: const Icon(Icons.lightbulb_outline,
                    color: AppTheme.accent),
                tooltip: "Minta petunjuk",
                onPressed: onHint,
              ),
              const Gap(4),
              // Text input
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "Tulis kalimatmu di sini...",
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onSubmitted: (_) => onSubmit(),
                ),
              ),
              const Gap(8),
              // Send button
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                ),
                child: IconButton(
                  icon: isValidating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: isValidating ? null : onSubmit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Finish bar ──
class _FinishBar extends StatelessWidget {
  final List<Word> targetWords;
  const _FinishBar({required this.targetWords});

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.celebration, color: AppTheme.success),
                Gap(8),
                Expanded(
                  child: Text(
                    "🎉 Selamat! Semua kata target sudah digunakan!",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () async {
                // Save to history
                try {
                  final historyRepo = getIt<IHistoryRepository>();
                  await historyRepo.markWordsLearned(targetWords);
                } catch (_) {}

                // Navigate back to home
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              icon: const Icon(Icons.check_circle),
              label: const Text("Selesai"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

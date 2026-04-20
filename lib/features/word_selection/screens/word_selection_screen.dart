import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:gap/gap.dart";
import "package:audioplayers/audioplayers.dart";
import "../../../core/theme/app_theme.dart";
import "../../../core/di/injection.dart";
import "../../../domain/entities/word.dart";
import "../../../domain/entities/dictionary_entry.dart";
import "../../../domain/repositories/i_story_repository.dart";
import "../../story_read/bloc/story_bloc.dart";
import "../../story_read/screens/story_read_screen.dart";
import "../bloc/word_selection_bloc.dart";
import "../bloc/word_selection_event.dart";
import "../bloc/word_selection_state.dart";

class WordSelectionScreen extends StatelessWidget {
  const WordSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vocably"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, "/settings"),
          ),
        ],
      ),
      body: BlocBuilder<WordSelectionBloc, WordSelectionState>(
        builder: (context, state) {
          if (state.status == WordSelectionStatus.loading &&
              state.wordsForTopic.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Topic selector
              _TopicSelector(
                topics: state.availableTopics,
                selectedTopic: state.selectedTopic,
              ),

              // Word bubbles (bento style)
              Expanded(
                flex: 3,
                child: _WordBentoGrid(
                  words: state.wordsForTopic,
                  selectedWords: state.selectedWords,
                  tappedWord: state.tappedWord,
                ),
              ),

              // Dictionary panel (shown when a word is tapped)
              if (state.tappedWord != null)
                Expanded(
                  flex: 4,
                  child: _DictionaryPanel(
                    word: state.tappedWord!,
                    entry: state.dictionaryEntry,
                    isLoading: state.isDictionaryLoading,
                    isSelected: state.selectedWords.contains(state.tappedWord),
                  ),
                ),

              // Selected words count & start button
              _BottomActionBar(
                selectedCount: state.selectedWords.length,
                canStart: state.canStartLearning,
                selectedWords: state.selectedWords,
                topic: state.selectedTopic,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Topic Dropdown ──
class _TopicSelector extends StatelessWidget {
  final List<String> topics;
  final String selectedTopic;

  const _TopicSelector({required this.topics, required this.selectedTopic});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.softShadow,
      ),
      child: DropdownButtonFormField<String>(
        initialValue: selectedTopic.isNotEmpty ? selectedTopic : null,
        decoration: InputDecoration(
          labelText: "Pilih Topik",
          prefixIcon:
              const Icon(Icons.category_outlined, color: AppTheme.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: topics
            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
            .toList(),
        onChanged: (topic) {
          if (topic != null) {
            context.read<WordSelectionBloc>().add(TopicSelected(topic));
          }
        },
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1);
  }
}

// ── Bento-style word grid ──
class _WordBentoGrid extends StatelessWidget {
  final List<Word> words;
  final List<Word> selectedWords;
  final Word? tappedWord;

  const _WordBentoGrid({
    required this.words,
    required this.selectedWords,
    this.tappedWord,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        children: words.asMap().entries.map((entry) {
          final index = entry.key;
          final word = entry.value;
          final isSelected = selectedWords.contains(word);
          final isTapped = tappedWord?.id == word.id;

          return _WordBubble(
            word: word,
            isSelected: isSelected,
            isTapped: isTapped,
            onTap: () {
              context.read<WordSelectionBloc>().add(WordTapped(word));
            },
            onLongPress: () {
              context.read<WordSelectionBloc>().add(WordToggled(word));
            },
          )
              .animate()
              .fadeIn(
                delay: (50 * index).ms,
                duration: 300.ms,
              )
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                delay: (50 * index).ms,
                duration: 300.ms,
              );
        }).toList(),
      ),
    );
  }
}

// ── Single word bubble ──
class _WordBubble extends StatelessWidget {
  final Word word;
  final bool isSelected;
  final bool isTapped;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _WordBubble({
    required this.word,
    required this.isSelected,
    required this.isTapped,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color borderColor;

    if (isSelected && isTapped) {
      bgColor = AppTheme.primary;
      textColor = Colors.white;
      borderColor = AppTheme.secondary;
    } else if (isSelected) {
      bgColor = AppTheme.primary;
      textColor = Colors.white;
      borderColor = AppTheme.primary;
    } else if (isTapped) {
      bgColor = AppTheme.wordBubble;
      textColor = AppTheme.primary;
      borderColor = AppTheme.primary;
    } else {
      bgColor = Colors.white;
      textColor = AppTheme.textPrimary;
      borderColor = Colors.grey.shade300;
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppTheme.chipRadius,
          border: Border.all(color: borderColor, width: isTapped ? 2 : 1.5),
          boxShadow: isTapped ? AppTheme.cardShadow : AppTheme.softShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              word.english,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const Gap(2),
            Text(
              word.indonesian,
              style: TextStyle(
                fontSize: 11,
                color: textColor.withValues(alpha: 0.7),
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(Icons.check_circle, size: 14, color: AppTheme.secondary),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Dictionary detail panel ──
class _DictionaryPanel extends StatelessWidget {
  final Word word;
  final DictionaryEntry? entry;
  final bool isLoading;
  final bool isSelected;

  const _DictionaryPanel({
    required this.word,
    this.entry,
    required this.isLoading,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardRadius,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        word.english.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                          letterSpacing: 1,
                        ),
                      ),
                      if (entry != null && entry!.phonetic.isNotEmpty)
                        Text(
                          entry!.phonetic,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                if (entry?.audioUrl != null)
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: AppTheme.primary),
                    onPressed: () async {
                      final player = AudioPlayer();
                      await player.play(UrlSource(entry!.audioUrl!));
                    },
                  ),
                IconButton(
                  icon: Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.add_circle_outline,
                    color: isSelected ? AppTheme.success : AppTheme.primary,
                  ),
                  tooltip: isSelected ? "Terpilih" : "Pilih kata ini",
                  onPressed: () {
                    context.read<WordSelectionBloc>().add(WordToggled(word));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    context
                        .read<WordSelectionBloc>()
                        .add(const DismissDictionary());
                  },
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : entry == null
                    ? Center(
                        child: Text(
                          "Definisi tidak tersedia",
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      )
                    : _buildContent(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.05);
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indonesian meaning
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Text("🇮🇩", style: TextStyle(fontSize: 16)),
                const Gap(8),
                Expanded(
                  child: Text(
                    word.indonesian,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          // English definitions
          ...entry!.meanings.map((meaning) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        meaning.partOfSpeech,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accent,
                        ),
                      ),
                    ),
                    const Gap(6),
                    ...meaning.definitions.take(2).map((def) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "• ${def.definition}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                              if (def.example != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 12, top: 2),
                                  child: Text(
                                    "\"${def.example}\"",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ── Bottom action bar ──
class _BottomActionBar extends StatelessWidget {
  final int selectedCount;
  final bool canStart;
  final List<Word> selectedWords;
  final String topic;

  const _BottomActionBar({
    required this.selectedCount,
    required this.canStart,
    required this.selectedWords,
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
          if (selectedCount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 16, color: AppTheme.success),
                  const Gap(6),
                  Text(
                    "$selectedCount kata dipilih (tekan lama untuk memilih/batal)",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: canStart
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => StoryBloc(
                              getIt<IStoryRepository>(),
                            ),
                            child: StoryReadScreen(
                              targetWords: selectedWords,
                              initialTitle: topic,
                            ),
                          ),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.auto_stories),
              label: const Text("Belajar Kata Baru dengan Cerita"),
              style: ElevatedButton.styleFrom(
                backgroundColor: canStart ? AppTheme.primary : Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import "package:flutter/material.dart";
import "../theme/app_theme.dart";
import "../../domain/entities/word.dart";

class WordHighlighter {
  WordHighlighter._();

  /// Build a list of TextSpan with target words highlighted and tappable.
  /// Handles punctuation attached to words (e.g., "apple," or "brave.").
  static List<InlineSpan> buildHighlightedSpans({
    required String text,
    required List<Word> targetWords,
    required Function(Word) onWordTap,
    TextStyle? baseStyle,
    TextStyle? highlightStyle,
  }) {
    final spans = <InlineSpan>[];
    final words = text.split(" ");

    for (int i = 0; i < words.length; i++) {
      final rawWord = words[i];
      if (i > 0) {
        spans.add(const TextSpan(text: " "));
      }

      // Strip punctuation for matching
      final cleaned = rawWord.replaceAll(RegExp(r"[^a-zA-Z]"), "").toLowerCase();
      final matchedTarget = targetWords.cast<Word?>().firstWhere(
        (w) => w!.english.toLowerCase() == cleaned,
        orElse: () => null,
      );

      if (matchedTarget != null) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () => onWordTap(matchedTarget),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.accent.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  rawWord,
                  style: highlightStyle ??
                      const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                ),
              ),
            ),
          ),
        );
      } else {
        spans.add(TextSpan(
          text: rawWord,
          style: baseStyle ??
              const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                height: 1.8,
              ),
        ));
      }
    }

    return spans;
  }
}
